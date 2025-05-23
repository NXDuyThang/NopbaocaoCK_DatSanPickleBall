using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using BLL.Interfaces;
using DAL.Models;
using Microsoft.Extensions.Logging;

namespace WebDatSanPickleBall.Areas.Admin.Pages.Users;

public class EditModel : PageModel
{
    private readonly IUserService _userService;
    private readonly ILogger<EditModel> _logger;
    public EditModel(IUserService userService, ILogger<EditModel> logger)
    {
        _userService = userService;
        _logger = logger;
    }

    [BindProperty]
    public User User { get; set; } = null!;
    [BindProperty]
    public string NewRole { get; set; } = null!;
    public List<string> Roles { get; set; } = new() { "User", "Admin", "Cashier" };

    public async Task<IActionResult> OnGetAsync(string id)
    {
        _logger.LogInformation("OnGetAsync called with id: {Id}", id);
        var user = await _userService.GetUserByIdAsync(id);
        if (user == null)
        {
            _logger.LogWarning("User not found with id: {Id}", id);
            return NotFound();
        }
        if (user.Role == "Admin")
        {
            _logger.LogWarning("Attempted to edit admin account: {Id}", id);
            return RedirectToPage("./Index");
        }
        User = user;
        NewRole = user.Role;
        return Page();
    }

    public async Task<IActionResult> OnPostAsync()
    {
        _logger.LogInformation("OnPostAsync called for user id: {Id}", User.Id);
        if (!ModelState.IsValid)
        {
            _logger.LogWarning("ModelState is invalid");
            return Page();
        }
        var user = await _userService.GetUserByIdAsync(User.Id);
        if (user == null)
        {
            _logger.LogWarning("User not found with id: {Id}", User.Id);
            return NotFound();
        }
        if (user.Role == "Admin")
        {
            _logger.LogWarning("Attempted to edit admin account: {Id}", User.Id);
            return RedirectToPage("./Index");
        }
        user.FullName = User.FullName;
        user.Email = User.Email;
        user.PhoneNumber = User.PhoneNumber;
        var updateResult = await _userService.UpdateUserAsync(user);
        _logger.LogInformation("UpdateUserAsync result: {Result}", updateResult);
        if (user.Role != NewRole)
        {
            var roleResult = await _userService.ChangeUserRoleAsync(user.Id, NewRole);
            _logger.LogInformation("ChangeUserRoleAsync result: {Result}", roleResult);
        }
        return RedirectToPage("./Index");
    }
} 