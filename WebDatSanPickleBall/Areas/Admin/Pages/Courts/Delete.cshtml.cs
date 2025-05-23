using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using BLL.Interfaces;
using DAL.Models;

namespace WebDatSanPickleBall.Areas.Admin.Pages.Courts;

public class DeleteModel : PageModel
{
    private readonly ICourtService _courtService;
    private readonly ILogger<DeleteModel> _logger;

    public DeleteModel(ICourtService courtService, ILogger<DeleteModel> logger)
    {
        _courtService = courtService;
        _logger = logger;
    }

    [BindProperty]
    public Court Court { get; set; } = null!;

    public async Task<IActionResult> OnGetAsync(int id)
    {
        try
        {
            var court = await _courtService.GetCourtByIdAsync(id);
            if (court == null)
            {
                return NotFound();
            }

            Court = court;
            return Page();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while getting court for delete");
            TempData["Error"] = "Có lỗi xảy ra khi tải thông tin sân";
            return RedirectToPage("./Index");
        }
    }

    public async Task<IActionResult> OnPostAsync(int id)
    {
        try
        {
            var result = await _courtService.DeleteCourtAsync(id);
            if (result)
            {
                TempData["Success"] = "Xóa sân thành công";
                return RedirectToPage("./Index");
            }
            else
            {
                TempData["Error"] = "Không thể xóa sân. Vui lòng thử lại.";
                return RedirectToPage("./Index");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while deleting court");
            TempData["Error"] = "Có lỗi xảy ra khi xóa sân";
            return RedirectToPage("./Index");
        }
    }
} 