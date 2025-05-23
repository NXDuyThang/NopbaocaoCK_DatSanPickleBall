using Microsoft.AspNetCore.Identity;
using DAL.Models;
using Microsoft.Extensions.Logging;

namespace WebDatSanPickleBall.Services;

public class AdminInitializer
{
    private readonly UserManager<User> _userManager;
    private readonly RoleManager<IdentityRole> _roleManager;
    private readonly IConfiguration _configuration;
    private readonly ILogger<AdminInitializer> _logger;

    public AdminInitializer(
        UserManager<User> userManager,
        RoleManager<IdentityRole> roleManager,
        IConfiguration configuration,
        ILogger<AdminInitializer> logger)
    {
        _userManager = userManager;
        _roleManager = roleManager;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task InitializeAsync()
    {
        try
        {
            // Tạo các role nếu chưa tồn tại
            string[] roleNames = { "Admin", "User", "Cashier" };
            foreach (var roleName in roleNames)
            {
                if (!await _roleManager.RoleExistsAsync(roleName))
                {
                    var result = await _roleManager.CreateAsync(new IdentityRole(roleName));
                    if (result.Succeeded)
                    {
                        _logger.LogInformation($"Created role: {roleName}");
                    }
                    else
                    {
                        _logger.LogError($"Failed to create role {roleName}: {string.Join(", ", result.Errors.Select(e => e.Description))}");
                    }
                }
            }

            // Tạo tài khoản admin nếu chưa tồn tại
            var adminEmail = _configuration["AdminUser:Email"] ?? "admin@datsanpickleball.com";
            var adminPassword = _configuration["AdminUser:Password"] ?? "Admin@123";

            var adminUser = await _userManager.FindByEmailAsync(adminEmail);
            if (adminUser == null)
            {
                adminUser = new User
                {
                    UserName = adminEmail,
                    Email = adminEmail,
                    EmailConfirmed = true,
                    FullName = "Administrator",
                    Role = "Admin",
                    CreatedAt = DateTime.UtcNow
                };

                var result = await _userManager.CreateAsync(adminUser, adminPassword);
                if (result.Succeeded)
                {
                    _logger.LogInformation("Created admin user successfully");
                    
                    // Gán role Admin
                    var roleResult = await _userManager.AddToRoleAsync(adminUser, "Admin");
                    if (roleResult.Succeeded)
                    {
                        _logger.LogInformation("Assigned Admin role to admin user");
                    }
                    else
                    {
                        _logger.LogError($"Failed to assign Admin role: {string.Join(", ", roleResult.Errors.Select(e => e.Description))}");
                    }
                }
                else
                {
                    _logger.LogError($"Failed to create admin user: {string.Join(", ", result.Errors.Select(e => e.Description))}");
                }
            }
            else
            {
                // Kiểm tra xem admin đã có role Admin chưa
                if (!await _userManager.IsInRoleAsync(adminUser, "Admin"))
                {
                    var roleResult = await _userManager.AddToRoleAsync(adminUser, "Admin");
                    if (roleResult.Succeeded)
                    {
                        _logger.LogInformation("Assigned Admin role to existing admin user");
                    }
                    else
                    {
                        _logger.LogError($"Failed to assign Admin role: {string.Join(", ", roleResult.Errors.Select(e => e.Description))}");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An error occurred while initializing admin user and roles");
            throw;
        }
    }
} 