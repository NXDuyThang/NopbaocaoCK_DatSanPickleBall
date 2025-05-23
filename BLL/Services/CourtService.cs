using Microsoft.EntityFrameworkCore;
using DAL.Models;
using BLL.Interfaces;
using DAL.Data;
using Microsoft.Extensions.Logging;

namespace BLL.Services;

public class CourtService : ICourtService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<CourtService> _logger;

    public CourtService(ApplicationDbContext context, ILogger<CourtService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<IEnumerable<Court>> GetAllCourtsAsync()
    {
        return await _context.Courts
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();
    }

    public async Task<Court?> GetCourtByIdAsync(int id)
    {
        return await _context.Courts.FindAsync(id);
    }

    public async Task<bool> CreateCourtAsync(Court court)
    {
        try
        {
            _logger.LogInformation("Bắt đầu thêm sân mới: {@Court}", court);

            // Kiểm tra dữ liệu đầu vào
            if (string.IsNullOrWhiteSpace(court.Name))
            {
                _logger.LogWarning("Tên sân không được để trống");
                return false;
            }

            if (string.IsNullOrWhiteSpace(court.Type))
            {
                _logger.LogWarning("Loại sân không được để trống");
                return false;
            }

            if (court.Price <= 0)
            {
                _logger.LogWarning("Giá sân phải lớn hơn 0");
                return false;
            }

            // Kiểm tra trùng tên sân
            var existingCourt = await _context.Courts
                .FirstOrDefaultAsync(c => c.Name == court.Name);
            if (existingCourt != null)
            {
                _logger.LogWarning("Đã tồn tại sân với tên: {Name}", court.Name);
                return false;
            }

            // Thêm sân mới
            court.CreatedAt = DateTime.Now; // Đặt thời gian tạo
            _context.Courts.Add(court);
            var result = await _context.SaveChangesAsync();
            
            if (result > 0)
            {
                _logger.LogInformation("Thêm sân thành công: {@Court}", court);
                return true;
            }
            else
            {
                _logger.LogWarning("Không có thay đổi nào được lưu vào database");
                return false;
            }
        }
        catch (DbUpdateException ex)
        {
            _logger.LogError(ex, "Lỗi khi cập nhật database: {Message}", ex.Message);
            if (ex.InnerException != null)
            {
                _logger.LogError("Inner Exception: {Message}", ex.InnerException.Message);
            }
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi không xác định khi thêm sân: {Message}", ex.Message);
            return false;
        }
    }

    public async Task<bool> UpdateCourtAsync(Court court)
    {
        try
        {
            _logger.LogInformation("Bắt đầu cập nhật sân: {@Court}", court);

            // Kiểm tra dữ liệu đầu vào
            if (string.IsNullOrWhiteSpace(court.Name))
            {
                _logger.LogWarning("Tên sân không được để trống");
                return false;
            }

            if (string.IsNullOrWhiteSpace(court.Type))
            {
                _logger.LogWarning("Loại sân không được để trống");
                return false;
            }

            if (string.IsNullOrWhiteSpace(court.Location))
            {
                _logger.LogWarning("Vị trí sân không được để trống");
                return false;
            }

            if (court.Price <= 0)
            {
                _logger.LogWarning("Giá sân phải lớn hơn 0");
                return false;
            }

            // Kiểm tra trùng tên sân (trừ chính nó)
            var existingCourt = await _context.Courts
                .FirstOrDefaultAsync(c => c.Name == court.Name && c.Id != court.Id);
            if (existingCourt != null)
            {
                _logger.LogWarning("Đã tồn tại sân khác với tên: {Name}", court.Name);
                return false;
            }

            // Lấy sân hiện tại từ database
            var currentCourt = await _context.Courts.FindAsync(court.Id);
            if (currentCourt == null)
            {
                _logger.LogWarning("Không tìm thấy sân với ID: {Id}", court.Id);
                return false;
            }

            // Cập nhật các thuộc tính
            currentCourt.Name = court.Name;
            currentCourt.Type = court.Type;
            currentCourt.Location = court.Location;
            currentCourt.Price = court.Price;
            currentCourt.Description = court.Description;
            currentCourt.IsActive = court.IsActive;

            var result = await _context.SaveChangesAsync();
            
            if (result > 0)
            {
                _logger.LogInformation("Cập nhật sân thành công: {@Court}", court);
                return true;
            }
            else
            {
                _logger.LogWarning("Không có thay đổi nào được lưu vào database");
                return false;
            }
        }
        catch (DbUpdateException ex)
        {
            _logger.LogError(ex, "Lỗi khi cập nhật database: {Message}", ex.Message);
            if (ex.InnerException != null)
            {
                _logger.LogError("Inner Exception: {Message}", ex.InnerException.Message);
            }
            return false;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi không xác định khi cập nhật sân: {Message}", ex.Message);
            return false;
        }
    }

    public async Task<bool> DeleteCourtAsync(int courtId)
    {
        try
        {
            var court = await _context.Courts.FirstOrDefaultAsync(c => c.Id == courtId);
            if (court == null)
                return false;

            _context.Courts.Remove(court);
            await _context.SaveChangesAsync();
            return true;
        }
        catch
        {
            return false;
        }
    }

    public async Task<bool> ToggleCourtStatusAsync(int id)
    {
        try
        {
            var court = await _context.Courts.FindAsync(id);
            if (court == null) return false;

            court.IsActive = !court.IsActive;
            await _context.SaveChangesAsync();
            return true;
        }
        catch
        {
            return false;
        }
    }

    public async Task<IEnumerable<Court>> GetAvailableCourtsAsync(DateTime date, TimeSpan startTime, TimeSpan endTime)
    {
        var bookingDate = DateOnly.FromDateTime(date);
        var startTimeOnly = TimeOnly.FromTimeSpan(startTime);
        var endTimeOnly = TimeOnly.FromTimeSpan(endTime);

        var bookedCourtIds = await _context.Bookings
            .Where(b => b.BookingDate == bookingDate && 
                       b.Status != BookingStatus.Cancelled &&
                       b.Status != BookingStatus.Completed &&
                       ((b.StartTime <= startTimeOnly && b.EndTime > startTimeOnly) ||
                        (b.StartTime < endTimeOnly && b.EndTime >= endTimeOnly) ||
                        (b.StartTime >= startTimeOnly && b.EndTime <= endTimeOnly)))
            .Select(b => b.CourtID)
            .Distinct()
            .ToListAsync();

        return await _context.Courts
            .Where(c => c.IsActive && !bookedCourtIds.Contains(c.Id))
            .ToListAsync();
    }

    public async Task<bool> IsCourtAvailableAsync(int courtId, DateTime date, TimeSpan startTime, TimeSpan endTime)
    {
        var court = await _context.Courts.FindAsync(courtId);
        if (court == null || !court.IsActive) return false;

        var bookingDate = DateOnly.FromDateTime(date);
        var startTimeOnly = TimeOnly.FromTimeSpan(startTime);
        var endTimeOnly = TimeOnly.FromTimeSpan(endTime);

        var hasBooking = await _context.Bookings
            .AnyAsync(b => b.CourtID == courtId &&
                          b.BookingDate == bookingDate &&
                          b.Status != BookingStatus.Cancelled &&
                          b.Status != BookingStatus.Completed &&
                          ((b.StartTime <= startTimeOnly && b.EndTime > startTimeOnly) ||
                           (b.StartTime < endTimeOnly && b.EndTime >= endTimeOnly) ||
                           (b.StartTime >= startTimeOnly && b.EndTime <= endTimeOnly)));

        return !hasBooking;
    }

    public async Task<decimal> GetCourtPriceAsync(int courtId, DateTime date, TimeSpan startTime, TimeSpan endTime)
    {
        var court = await _context.Courts.FindAsync(courtId);
        if (court == null) return 0;

        var hours = (endTime - startTime).TotalHours;
        return court.Price * (decimal)hours;
    }
} 