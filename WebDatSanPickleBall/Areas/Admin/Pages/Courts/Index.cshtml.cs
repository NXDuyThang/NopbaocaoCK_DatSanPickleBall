using Microsoft.AspNetCore.Mvc.RazorPages;
using BLL.Interfaces;
using DAL.Models;

namespace WebDatSanPickleBall.Areas.Admin.Pages.Courts;

public class IndexModel : PageModel
{
    private readonly ICourtService _courtService;
    private readonly ILogger<IndexModel> _logger;

    public IndexModel(ICourtService courtService, ILogger<IndexModel> logger)
    {
        _courtService = courtService;
        _logger = logger;
    }

    public IList<Court> Courts { get; set; } = new List<Court>();
    public int CourtCount { get; set; }

    public async Task OnGetAsync()
    {
        try
        {
            var courts = await _courtService.GetAllCourtsAsync();
            Courts = courts.ToList();
            CourtCount = Courts.Count;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while getting courts list");
            TempData["Error"] = "Có lỗi xảy ra khi tải danh sách sân";
        }
    }
} 