using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using BLL.Interfaces;
using DAL.Models;

namespace WebDatSanPickleBall.Areas.Admin.Pages.Courts;

public class EditModel : PageModel
{
    private readonly ICourtService _courtService;
    private readonly ILogger<EditModel> _logger;

    public EditModel(ICourtService courtService, ILogger<EditModel> logger)
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
            _logger.LogError(ex, "Error occurred while getting court for edit");
            TempData["Error"] = "Có lỗi xảy ra khi tải thông tin sân";
            return RedirectToPage("./Index");
        }
    }

    public async Task<IActionResult> OnPostAsync()
    {
        if (!ModelState.IsValid)
        {
            return Page();
        }

        try
        {
            var result = await _courtService.UpdateCourtAsync(Court);
            if (result)
            {
                TempData["Success"] = "Cập nhật sân thành công";
                return RedirectToPage("./Index");
            }
            else
            {
                ModelState.AddModelError(string.Empty, "Không thể cập nhật sân. Vui lòng thử lại.");
                return Page();
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while updating court");
            ModelState.AddModelError(string.Empty, "Có lỗi xảy ra khi cập nhật sân");
            return Page();
        }
    }
} 