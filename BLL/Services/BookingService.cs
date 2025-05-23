using DAL.Models;
using BLL.Interfaces;
using DAL.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace BLL.Services;

public class BookingService : IBookingService
{
    private readonly ApplicationDbContext _context;
    private readonly ICourtService _courtService;
    private readonly ILogger<BookingService> _logger;

    public BookingService(ApplicationDbContext context, ICourtService courtService, ILogger<BookingService> logger)
    {
        _context = context;
        _courtService = courtService;
        _logger = logger;
    }

    public async Task<Booking> GetBookingByIdAsync(int id)
    {
        return await _context.Bookings
            .Include(b => b.Court)
            .Include(b => b.User)
            .FirstOrDefaultAsync(b => b.BookingID == id);
    }

    public async Task<IEnumerable<Booking>> GetAllBookingsAsync()
    {
        return await _context.Bookings
            .Include(b => b.User)
            .Include(b => b.Court)
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync();
    }

    public async Task<IEnumerable<Booking>> GetUserBookingsAsync(string userId)
    {
        return await _context.Bookings
            .Include(b => b.Court)
            .Where(b => b.UserId == userId)
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync();
    }

    public async Task<IEnumerable<Booking>> GetCourtBookingsAsync(int courtId, DateTime date)
    {
        var bookingDate = DateOnly.FromDateTime(date);
        return await _context.Bookings
            .Include(b => b.User)
            .Where(b => b.CourtID == courtId && b.BookingDate == bookingDate)
            .OrderBy(b => b.StartTime)
            .ToListAsync();
    }

    public async Task<bool> CreateBookingAsync(Booking booking)
    {
        try
        {
            // Kiểm tra sân có tồn tại và đang hoạt động không
            var court = await _courtService.GetCourtByIdAsync(booking.CourtID);
            if (court == null || !court.IsActive) return false;

            // Kiểm tra thời gian đặt có hợp lệ không
            if (booking.StartTime >= booking.EndTime) return false;

            // Kiểm tra sân có trống không
            if (!await _courtService.IsCourtAvailableAsync(booking.CourtID, booking.BookingDate.ToDateTime(TimeOnly.MinValue), booking.StartTime.ToTimeSpan(), booking.EndTime.ToTimeSpan()))
                return false;

            // Calculate total amount
            var hours = (booking.EndTime - booking.StartTime).TotalHours;
            var totalAmount = court.Price * (decimal)hours;

            booking.TotalAmount = totalAmount;

            // Mặc định trạng thái là Pending
            booking.Status = BookingStatus.Pending;
            booking.CreatedAt = DateTime.UtcNow;

            await _context.Bookings.AddAsync(booking);
            await _context.SaveChangesAsync();
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi tạo đặt sân mới");
            return false;
        }
    }

    public async Task<bool> UpdateBookingAsync(Booking booking)
    {
        try
        {
            var existingBooking = await _context.Bookings.FindAsync(booking.BookingID);
            if (existingBooking == null) return false;

            // Nếu đã xác nhận hoặc hủy thì không cho phép cập nhật
            if (existingBooking.Status == BookingStatus.Confirmed || 
                existingBooking.Status == BookingStatus.Cancelled)
                return false;

            // Kiểm tra sân mới có trống không (nếu thay đổi sân)
            if (existingBooking.CourtID != booking.CourtID || 
                existingBooking.BookingDate != booking.BookingDate ||
                existingBooking.StartTime != booking.StartTime ||
                existingBooking.EndTime != booking.EndTime)
            {
                if (!await _courtService.IsCourtAvailableAsync(booking.CourtID, booking.BookingDate.ToDateTime(TimeOnly.MinValue), booking.StartTime.ToTimeSpan(), booking.EndTime.ToTimeSpan()))
                    return false;

                // Tính lại giá tiền
                booking.TotalAmount = await _courtService.GetCourtPriceAsync(booking.CourtID, booking.BookingDate.ToDateTime(TimeOnly.MinValue), booking.StartTime.ToTimeSpan(), booking.EndTime.ToTimeSpan());
            }

            _context.Entry(existingBooking).CurrentValues.SetValues(booking);
            await _context.SaveChangesAsync();
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi cập nhật đặt sân");
            return false;
        }
    }

    public async Task<bool> CancelBookingAsync(int id)
    {
        try
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return false;

            // Chỉ cho phép hủy nếu chưa xác nhận
            if (booking.Status != BookingStatus.Confirmed)
            {
                booking.Status = BookingStatus.Cancelled;
                await _context.SaveChangesAsync();
                return true;
            }

            return false;
        }
        catch
        {
            return false;
        }
    }

    public async Task<bool> ConfirmBookingAsync(int id)
    {
        try
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return false;

            // Chỉ cho phép xác nhận nếu đang ở trạng thái Pending
            if (booking.Status == BookingStatus.Pending)
            {
                booking.Status = BookingStatus.Confirmed;
                await _context.SaveChangesAsync();
                return true;
            }

            return false;
        }
        catch
        {
            return false;
        }
    }

    public async Task<bool> IsTimeSlotAvailableAsync(int courtId, DateTime date, TimeSpan startTime, TimeSpan endTime)
    {
        return await _courtService.IsCourtAvailableAsync(courtId, date, startTime, endTime);
    }

    public async Task<decimal> CalculateBookingPriceAsync(int courtId, DateTime date, TimeSpan startTime, TimeSpan endTime)
    {
        return await _courtService.GetCourtPriceAsync(courtId, date, startTime, endTime);
    }

    public async Task<IEnumerable<Booking>> GetBookingsByUserIdAsync(string userId)
    {
        return await _context.Bookings
            .Include(b => b.Court)
            .Where(b => b.UserId == userId)
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync();
    }

    public async Task<IEnumerable<Booking>> GetBookingsByCourtIdAsync(int courtId)
    {
        return await _context.Bookings
            .Include(b => b.User)
            .Where(b => b.CourtID == courtId)
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync();
    }

    public async Task<bool> DeleteBookingAsync(int id)
    {
        try
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return false;

            _context.Bookings.Remove(booking);
            await _context.SaveChangesAsync();
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi xóa đặt sân");
            return false;
        }
    }

    public async Task<bool> UpdateBookingStatusAsync(int id, BookingStatus status)
    {
        try
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return false;

            booking.Status = status;
            await _context.SaveChangesAsync();
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi cập nhật trạng thái đặt sân");
            return false;
        }
    }
} 