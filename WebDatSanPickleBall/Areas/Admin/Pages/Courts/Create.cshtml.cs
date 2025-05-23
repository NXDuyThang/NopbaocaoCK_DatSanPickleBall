using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using BLL.Interfaces;
using DAL.Models;

namespace WebDatSanPickleBall.Areas.Admin.Pages.Courts;

public class CreateModel : PageModel
{
    private readonly ICourtService _courtService;
    private readonly ILogger<CreateModel> _logger;

    public CreateModel(ICourtService courtService, ILogger<CreateModel> logger)
    {
        _courtService = courtService;
        _logger = logger;
    }

    [BindProperty]
    public Court Court { get; set; } = null!;

    public IActionResult OnGet()
    {
        _logger.LogInformation("Truy cập trang thêm sân mới");
        return Page();
    }

    public async Task<IActionResult> OnPostAsync()
    {
        _logger.LogInformation("Bắt đầu xử lý yêu cầu thêm sân mới: {@Court}", Court);

        if (!ModelState.IsValid)
        {
            _logger.LogWarning("Dữ liệu không hợp lệ: {@ModelState}", ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage));
            return Page();
        }

        try
        {
            // Kiểm tra dữ liệu đầu vào
            if (string.IsNullOrWhiteSpace(Court.Name))
            {
                ModelState.AddModelError("Court.Name", "Tên sân không được để trống");
                _logger.LogWarning("Tên sân không được để trống");
                return Page();
            }

            if (string.IsNullOrWhiteSpace(Court.Type))
            {
                ModelState.AddModelError("Court.Type", "Loại sân không được để trống");
                _logger.LogWarning("Loại sân không được để trống");
                return Page();
            }

            if (Court.Price <= 0)
            {
                ModelState.AddModelError("Court.Price", "Giá sân phải lớn hơn 0");
                _logger.LogWarning("Giá sân phải lớn hơn 0");
                return Page();
            }

            var result = await _courtService.CreateCourtAsync(Court);
            if (result)
            {
                _logger.LogInformation("Thêm sân thành công: {@Court}", Court);
                TempData["Success"] = "Thêm sân thành công";
                return RedirectToPage("./Index");
            }
            else
            {
                _logger.LogWarning("Không thể thêm sân. Vui lòng kiểm tra lại thông tin.");
                ModelState.AddModelError(string.Empty, "Không thể thêm sân. Vui lòng thử lại.");
                return Page();
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi thêm sân: {Message}", ex.Message);
            if (ex.InnerException != null)
            {
                _logger.LogError("Inner Exception: {Message}", ex.InnerException.Message);
            }
            ModelState.AddModelError(string.Empty, "Có lỗi xảy ra khi thêm sân");
            return Page();
        }
    }
} 