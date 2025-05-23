using Microsoft.AspNetCore.Mvc.RazorPages;
using BLL.Interfaces;
using DAL.Models;

namespace WebDatSanPickleBall.Areas.Admin.Pages.Users;

public class IndexModel : PageModel
{
    private readonly IUserService _userService;
    public List<User> Users { get; set; } = new();

    public IndexModel(IUserService userService)
    {
        _userService = userService;
    }

    public async Task OnGetAsync()
    {
        Users = (await _userService.GetAllUsersAsync()).ToList();
    }
} 