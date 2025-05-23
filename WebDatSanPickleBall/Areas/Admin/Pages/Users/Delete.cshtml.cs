using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using BLL.Interfaces;
using DAL.Models;

namespace WebDatSanPickleBall.Areas.Admin.Pages.Users;

public class DeleteModel : PageModel
{
    private readonly IUserService _userService;
    public DeleteModel(IUserService userService)
    {
        _userService = userService;
    }

    public User User { get; set; } = null!;

    public async Task<IActionResult> OnGetAsync(string id)
    {
        var user = await _userService.GetUserByIdAsync(id);
        if (user == null) return NotFound();
        if (user.Role == "Admin")
        {
            return RedirectToPage("./Index");
        }
        User = user;
        return Page();
    }

    public async Task<IActionResult> OnPostAsync(string id)
    {
        var user = await _userService.GetUserByIdAsync(id);
        if (user == null) return NotFound();
        if (user.Role == "Admin")
        {
            return RedirectToPage("./Index");
        }
        var result = await _userService.DeleteUserAsync(id);
        if (!result) return NotFound();
        return RedirectToPage("Index");
    }
} 