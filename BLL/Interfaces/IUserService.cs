using DAL.Models;

namespace BLL.Interfaces;

public interface IUserService
{
    Task<User> GetUserByIdAsync(string id);
    Task<User> GetUserByEmailAsync(string email);
    Task<IEnumerable<User>> GetAllUsersAsync();
    Task<IEnumerable<User>> GetUsersByRoleAsync(string role);
    Task<bool> UpdateUserAsync(User user);
    Task<bool> DeleteUserAsync(string id);
    Task<bool> ChangeUserRoleAsync(string userId, string newRole);
    Task<bool> IsUserInRoleAsync(string userId, string role);
} 