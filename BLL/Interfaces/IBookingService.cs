using DAL.Models;

namespace BLL.Interfaces;

public interface IBookingService
{
    Task<Booking?> GetBookingByIdAsync(int id);
    Task<IEnumerable<Booking>> GetAllBookingsAsync();
    Task<IEnumerable<Booking>> GetUserBookingsAsync(string userId);
    Task<IEnumerable<Booking>> GetCourtBookingsAsync(int courtId, DateTime date);
    Task<bool> CreateBookingAsync(Booking booking);
    Task<bool> UpdateBookingAsync(Booking booking);
    Task<bool> CancelBookingAsync(int id);
    Task<bool> ConfirmBookingAsync(int id);
    Task<bool> IsTimeSlotAvailableAsync(int courtId, DateTime date, TimeSpan startTime, TimeSpan endTime);
    Task<decimal> CalculateBookingPriceAsync(int courtId, DateTime date, TimeSpan startTime, TimeSpan endTime);
    Task<IEnumerable<Booking>> GetBookingsByUserIdAsync(string userId);
    Task<IEnumerable<Booking>> GetBookingsByCourtIdAsync(int courtId);
    Task<bool> DeleteBookingAsync(int id);
    Task<bool> UpdateBookingStatusAsync(int id, BookingStatus status);
} 