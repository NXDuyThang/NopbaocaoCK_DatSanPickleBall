using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using DAL.Data;
using DAL.Models;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using BLL.Interfaces;
using WebDatSanPickleBall.Models;

namespace WebDatSanPickleBall.Controllers
{
    public class CourtsController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly ICourtService _courtService;
        private readonly IBookingService _bookingService;

        public CourtsController(ApplicationDbContext context, ICourtService courtService, IBookingService bookingService)
        {
            _context = context;
            _courtService = courtService;
            _bookingService = bookingService;
        }

        // GET: Courts
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

            ViewData["SearchString"] = searchString;
            ViewData["CourtType"] = courtType;
            ViewData["MinPrice"] = minPrice;
            ViewData["MaxPrice"] = maxPrice;
            
            return View(courts);
        }

        // GET: Courts/Details/5
        public async Task<IActionResult> Details(int id)
        {
            var court = await _courtService.GetCourtByIdAsync(id);
            if (court == null)
            {
                return NotFound();
            }

            // Lấy danh sách đặt sân của sân này
            var bookings = await _bookingService.GetBookingsByCourtIdAsync(id);
            var bookingViewModels = bookings.Select(b => new BookingViewModel
            {
                Id = b.BookingID,
                Title = $"Đặt sân - {b.User.FullName}",
                Start = b.BookingDate.ToDateTime(b.StartTime),
                End = b.BookingDate.ToDateTime(b.EndTime),
                Color = b.Status switch
                {
                    BookingStatus.Pending => "#ffc107", // Màu vàng cho trạng thái chờ xác nhận
                    BookingStatus.Confirmed => "#28a745", // Màu xanh lá cho trạng thái đã xác nhận
                    BookingStatus.Cancelled => "#dc3545", // Màu đỏ cho trạng thái đã hủy
                    BookingStatus.Completed => "#17a2b8", // Màu xanh dương cho trạng thái hoàn thành
                    _ => "#6c757d" // Màu xám cho các trạng thái khác
                }
            }).ToList();

            var viewModel = new CourtDetailsViewModel
            {
                Court = court,
                Bookings = bookingViewModels
            };

            return View(viewModel);
        }

        // POST: Courts/Book
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Book(int courtId, DateOnly bookingDate, TimeOnly startTime, TimeOnly endTime, string? notes)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var court = await _courtService.GetCourtByIdAsync(courtId);
            
            if (court == null) return NotFound("Sân không tồn tại");
            if (!court.IsActive)
                return BadRequest("Sân này hiện không hoạt động, không thể đặt sân");

            // Validate booking time
            //if (startTime >= endTime)
            //    return BadRequest("Thời gian kết thúc phải sau thời gian bắt đầu");

            if (bookingDate < DateOnly.FromDateTime(DateTime.Now))
                return BadRequest("Không thể đặt sân trong quá khứ");

            // Check if court is available
            var existingBooking = await _context.Bookings
                .AnyAsync(b => b.CourtID == courtId 
                    && b.BookingDate == bookingDate 
                    && (b.Status == BookingStatus.Pending || b.Status == BookingStatus.Confirmed)
                    && (b.StartTime < endTime && b.EndTime > startTime));

            if (existingBooking)
                return BadRequest("Sân đã được đặt trong khoảng thời gian này");

            // Calculate total price
            var hours = (endTime - startTime).TotalHours;
            var totalAmount = court.Price * (decimal)hours;

            var booking = new Booking
            {
                UserId = userId,
                CourtID = courtId,
                BookingDate = bookingDate,
                StartTime = startTime,
                EndTime = endTime,
                TotalAmount = totalAmount,
                Notes = notes,
                Status = BookingStatus.Pending,
                CreatedAt = DateTime.UtcNow
            };

            _context.Bookings.Add(booking);
            await _context.SaveChangesAsync();

            return RedirectToAction(nameof(BookingsController.Index), "Bookings");
        }

        // GET: Courts/GetAvailableTimeSlots
        [HttpGet]
        public async Task<IActionResult> GetAvailableTimeSlots(int courtId, DateOnly date)
        {
            var court = await _courtService.GetCourtByIdAsync(courtId);
            if (court == null) return NotFound();

            // Get court's time slots for the day
            var timeSlots = await _context.TimeSlots
                .Where(t => t.CourtID == courtId && t.DayOfWeek == date.DayOfWeek)
                .ToListAsync();

            // Get existing bookings
            var bookings = await _context.Bookings
                .Where(b => b.CourtID == courtId 
                    && b.BookingDate == date 
                    && b.Status != BookingStatus.Cancelled)
                .ToListAsync();

            // Check court availability
            var availability = await _context.CourtAvailabilities
                .FirstOrDefaultAsync(a => a.CourtID == courtId && a.Date == date);

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

            return Json(availableSlots);
        }
    }
} 