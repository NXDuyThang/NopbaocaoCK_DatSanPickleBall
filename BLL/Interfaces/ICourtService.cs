using DAL.Models;

namespace BLL.Interfaces;

public interface ICourtService
{
    Task<IEnumerable<Court>> GetAllCourtsAsync();
    Task<Court?> GetCourtByIdAsync(int id);
    Task<bool> CreateCourtAsync(Court court);
    Task<bool> UpdateCourtAsync(Court court);
    Task<bool> DeleteCourtAsync(int id);
    Task<bool> ToggleCourtStatusAsync(int id);
    Task<IEnumerable<Court>> GetAvailableCourtsAsync(DateTime date, TimeSpan startTime, TimeSpan endTime);
    Task<bool> IsCourtAvailableAsync(int courtId, DateTime date, TimeSpan startTime, TimeSpan endTime);
    Task<decimal> GetCourtPriceAsync(int courtId, DateTime date, TimeSpan startTime, TimeSpan endTime);
} 