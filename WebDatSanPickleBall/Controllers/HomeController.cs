using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using WebDatSanPickleBall.Models;
using BLL.Interfaces;
using DAL.Data;
using Microsoft.EntityFrameworkCore;

namespace WebDatSanPickleBall.Controllers
{
    public class HomeController : Controller
    {
        private readonly ICourtService _courtService;
        private readonly ApplicationDbContext _context;
        private readonly ILogger<HomeController> _logger;

        public HomeController(
            ICourtService courtService,
            ApplicationDbContext context,
            ILogger<HomeController> logger)
        {
            _courtService = courtService;
            _context = context;
            _logger = logger;
        }

        public async Task<IActionResult> Index(string searchString, string courtType, decimal? minPrice, decimal? maxPrice)
        {
            var courts = await _courtService.GetAllCourtsAsync();
            
            // Apply filters
            if (!string.IsNullOrEmpty(searchString))
            {
                courts = courts.Where(c => c.Name.Contains(searchString) || c.Location.Contains(searchString));
            }
            
            if (!string.IsNullOrEmpty(courtType))
            {
                courts = courts.Where(c => c.Type == courtType);
            }
            
            if (minPrice.HasValue)
            {
                courts = courts.Where(c => c.Price >= minPrice.Value);
            }
            
            if (maxPrice.HasValue)
            {
                courts = courts.Where(c => c.Price <= maxPrice.Value);
            }

            // Get today's bookings for each court
            var today = DateOnly.FromDateTime(DateTime.Now);
            var bookings = await _context.Bookings
                .Where(b => b.BookingDate == today && 
                           b.Status != DAL.Models.BookingStatus.Cancelled &&
                           b.Status != DAL.Models.BookingStatus.Completed)
                .ToListAsync();

            // Get court types for filter dropdown
            var courtTypes = courts.Select(c => c.Type).Distinct().ToList();

            ViewData["SearchString"] = searchString;
            ViewData["CourtType"] = courtType;
            ViewData["MinPrice"] = minPrice;
            ViewData["MaxPrice"] = maxPrice;
            ViewData["CourtTypes"] = courtTypes;
            ViewData["TodayBookings"] = bookings;
            ViewData["Today"] = today;

            return View(courts);
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        [HttpGet]
        [Route("Home/CourtDetails/{courtId:int}")]
        public async Task<IActionResult> CourtDetails(int courtId)
        {
            var court = await _courtService.GetCourtByIdAsync(courtId);
            if (court == null)
                return NotFound();

            // Get today's bookings for this court
            var today = DateOnly.FromDateTime(DateTime.Now);
            var bookings = await _context.Bookings
                .Where(b => b.CourtID == courtId && 
                           b.BookingDate == today && 
                           b.Status != DAL.Models.BookingStatus.Cancelled &&
                           b.Status != DAL.Models.BookingStatus.Completed)
                .ToListAsync();

            // Get court's time slots for today
            var timeSlots = await _context.TimeSlots
                .Where(t => t.CourtID == courtId && t.DayOfWeek == today.DayOfWeek)
                .ToListAsync();

            // Check court availability
            var availability = await _context.CourtAvailabilities
                .FirstOrDefaultAsync(a => a.CourtID == courtId && a.Date == today);

            ViewData["TodayBookings"] = bookings;
            ViewData["TimeSlots"] = timeSlots;
            ViewData["Availability"] = availability;
            ViewData["Today"] = today;

            return View(court);
        }

        // GET: Home/GetCourtAvailability/5
        [HttpGet]
        public async Task<IActionResult> GetCourtAvailability(int id, DateOnly date)
        {
            var court = await _courtService.GetCourtByIdAsync(id);
            if (court == null)
                return NotFound();

            // Get bookings for the date
            var bookings = await _context.Bookings
                .Where(b => b.CourtID == id && b.BookingDate == date && 
                           b.Status != DAL.Models.BookingStatus.Cancelled &&
                           b.Status != DAL.Models.BookingStatus.Completed)
                .ToListAsync();

            // Get court's time slots for the day
            var timeSlots = await _context.TimeSlots
                .Where(t => t.CourtID == id && t.DayOfWeek == date.DayOfWeek)
                .ToListAsync();

            // Check court availability
            var availability = await _context.CourtAvailabilities
                .FirstOrDefaultAsync(a => a.CourtID == id && a.Date == date);

            var availableSlots = new List<object>();
            foreach (var slot in timeSlots)
            {
                var isBooked = bookings.Any(b => 
                    (b.StartTime <= slot.StartTime && b.EndTime > slot.StartTime) ||
                    (b.StartTime < slot.EndTime && b.EndTime >= slot.EndTime));

                if (!isBooked && (availability == null || availability.IsAvailable))
                {
                    availableSlots.Add(new
                    {
                        startTime = slot.StartTime,
                        endTime = slot.EndTime,
                        price = court.Price
                    });
                }
            }

            return Json(new
            {
                isAvailable = availability == null || availability.IsAvailable,
                availableSlots,
                note = availability?.Note
            });
        }
    }
}
