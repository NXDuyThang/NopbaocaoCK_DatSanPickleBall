namespace WebDatSanPickleBall.Controllers
{
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.AspNetCore.Authorization;
    using DAL.Data;
    using DAL.Models;
    using Microsoft.EntityFrameworkCore;
    using System.Security.Claims;

    [Authorize]
    public class BookingsController : Controller
    {
        private readonly ApplicationDbContext _context;

        public BookingsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Bookings
        public async Task<IActionResult> Index(string? status, DateOnly? fromDate, DateOnly? toDate)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var query = _context.Bookings
                .Include(b => b.Court)
                .Include(b => b.Payment)
                .Where(b => b.UserId == userId);

            // Apply filters
            if (!string.IsNullOrEmpty(status) && Enum.TryParse<BookingStatus>(status, out var bookingStatus))
            {
                query = query.Where(b => b.Status == bookingStatus);
            }

            if (fromDate.HasValue)
            {
                query = query.Where(b => b.BookingDate >= fromDate.Value);
            }

            if (toDate.HasValue)
            {
                query = query.Where(b => b.BookingDate <= toDate.Value);
            }

            var bookings = await query
                .OrderByDescending(b => b.BookingDate)
                .ThenByDescending(b => b.StartTime)
                .ToListAsync();

            ViewData["Status"] = status;
            ViewData["FromDate"] = fromDate;
            ViewData["ToDate"] = toDate;

            return View(bookings);
        }

        // GET: Bookings/Create
        public async Task<IActionResult> Create(int courtId)
        {
            var court = await _context.Courts.FindAsync(courtId);
            if (court == null)
            {
                return NotFound();
            }

            ViewData["Court"] = court;
            return View();
        }

        // POST: Bookings/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(int courtId, DateOnly bookingDate, TimeOnly startTime, TimeOnly endTime)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null) return Unauthorized();

            var court = await _context.Courts.FindAsync(courtId);
            if (court == null) return NotFound();
            if (!court.IsActive)
            {
                ModelState.AddModelError("", "Sân này hiện không hoạt động, không thể đặt sân.");
                ViewData["Court"] = court;
                return View();
            }

            // Check if court is available
            var isAvailable = await _context.Bookings
                .AnyAsync(b => b.CourtID == courtId &&
                              b.BookingDate == bookingDate &&
                              (b.Status == BookingStatus.Pending || b.Status == BookingStatus.Confirmed) &&
                              (b.StartTime < endTime && b.EndTime > startTime));

            if (isAvailable)
            {
                ModelState.AddModelError("", "Sân đã được đặt trong khoảng thời gian này.");
                ViewData["Court"] = court;
                return View();
            }

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
                Status = BookingStatus.Pending,
                CreatedAt = DateTime.UtcNow
            };

            _context.Bookings.Add(booking);
            await _context.SaveChangesAsync();

            return RedirectToAction(nameof(Index));
        }

        // GET: Bookings/Details/5
        public async Task<IActionResult> Details(int id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var booking = await _context.Bookings
                .Include(b => b.Court)
                .Include(b => b.Payment)
                .FirstOrDefaultAsync(b => b.BookingID == id && b.UserId == userId);

            if (booking == null)
            {
                return NotFound();
            }

            return View(booking);
        }

        // GET: Bookings/CancelConfirmation/5
        public async Task<IActionResult> CancelConfirmation(int id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var booking = await _context.Bookings
                .Include(b => b.Court)
                .FirstOrDefaultAsync(b => b.BookingID == id && b.UserId == userId);

            if (booking == null)
                return NotFound();

            // Chỉ cho phép hủy nếu chưa xác nhận hoặc đã xác nhận nhưng chưa hoàn thành
            if (booking.Status == BookingStatus.Completed)
                return BadRequest("Không thể hủy đặt sân đã hoàn thành.");

            return View("Cancel", booking);
        }

        // POST: Bookings/Cancel/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Cancel(int id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var booking = await _context.Bookings
                .FirstOrDefaultAsync(b => b.BookingID == id && b.UserId == userId);

            if (booking == null)
                return NotFound();

            // Chỉ cho phép hủy nếu chưa hoàn thành
            if (booking.Status != BookingStatus.Completed)
            {
                booking.Status = BookingStatus.Cancelled;
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }

            return BadRequest("Không thể hủy đặt sân đã hoàn thành.");
        }

        // GET: Bookings/GetBookingStatus/5
        [HttpGet]
        public async Task<IActionResult> GetBookingStatus(int id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var booking = await _context.Bookings
                .Include(b => b.Payment)
                .FirstOrDefaultAsync(b => b.BookingID == id && b.UserId == userId);

            if (booking == null)
            {
                return NotFound();
            }

            var status = new
            {
                booking.Status,
                PaymentStatus = booking.Payment?.PaymentStatus,
                CanCancel = booking.Status != BookingStatus.Completed && 
                           booking.Status != BookingStatus.Cancelled,
                IsPast = booking.BookingDate.ToDateTime(booking.StartTime) <= DateTime.Now
            };

            return Json(status);
        }
    }
}
