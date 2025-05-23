using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using DAL.Data;
using DAL.Models;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace Controllers
{
    [Authorize]
    public class BookingController : Controller
    {
        private readonly ApplicationDbContext _context;
        public BookingController(ApplicationDbContext context)
        {
            _context = context;
        }

        // Đặt sân (POST)
        [HttpPost]
        public async Task<IActionResult> BookCourt(int courtId, string bookingDate, string bookingTime)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null) return Unauthorized();

            if (!DateOnly.TryParse(bookingDate, out var date) || !TimeOnly.TryParse(bookingTime, out var startTime))
                return BadRequest();

            var court = await _context.Courts.FindAsync(courtId);
            if (court == null) return NotFound();

            var endTime = startTime.AddHours(1); // Mặc định 1 tiếng
            var totalPrice = court.Price;

            var booking = new Booking
            {
                UserId = userId,
                CourtID = courtId,
                BookingDate = date,
                StartTime = startTime,
                EndTime = endTime,
                TotalAmount = totalPrice,
                TotalPrice = totalPrice,
                Status = BookingStatus.Pending,
                CreatedAt = DateTime.UtcNow
            };
            _context.Bookings.Add(booking);
            await _context.SaveChangesAsync();
            return Json(new { success = true });
        }

        // Lịch đặt của tôi
        public async Task<IActionResult> MyBookings()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null) return Unauthorized();
            var myBookings = await _context.Bookings
                .Include(b => b.Court)
                .Where(b => b.UserId == userId)
                .OrderByDescending(b => b.BookingDate)
                .ThenByDescending(b => b.StartTime)
                .ToListAsync();
            return View(myBookings);
        }
    }
} 