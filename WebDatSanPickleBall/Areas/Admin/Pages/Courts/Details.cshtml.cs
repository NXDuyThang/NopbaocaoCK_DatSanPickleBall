using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using BLL.Interfaces;
using DAL.Models;

namespace WebDatSanPickleBall.Areas.Admin.Pages.Courts;

public class DetailsModel : PageModel
{
    private readonly ICourtService _courtService;
    private readonly ILogger<DetailsModel> _logger;

    public DetailsModel(ICourtService courtService, ILogger<DetailsModel> logger)
    {
        _courtService = courtService;
        _logger = logger;
    }

    public Court Court { get; set; } = null!;

    public async Task<IActionResult> OnGetAsync(int id)
    {
        try
        {
            var court = await _courtService.GetCourtByIdAsync(id);
            if (court == null)
            {
                _logger.LogWarning("Không tìm thấy sân với ID: {Id}", id);
                return NotFound();
            }

            Court = court;
            return Page();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi tải thông tin sân với ID: {Id}", id);
            TempData["Error"] = "Có lỗi xảy ra khi tải thông tin sân";
            return RedirectToPage("./Index");
        }
    }
} 