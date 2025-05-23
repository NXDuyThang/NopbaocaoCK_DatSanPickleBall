using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using DAL.Data;
using DAL.Models;

namespace WebDatSanPickleBall.Areas.Admin.Pages.Bookings
{
    public class IndexModel : PageModel
    {
        private readonly ApplicationDbContext _context;
        public IndexModel(ApplicationDbContext context)
        {
            _context = context;
        }

        public List<Booking> Bookings { get; set; } = new();

        [BindProperty(SupportsGet = true)]
        public string? UserName { get; set; }
        [BindProperty(SupportsGet = true)]
        public string? CourtName { get; set; }
        [BindProperty(SupportsGet = true)]
        public string? Status { get; set; }
        [BindProperty(SupportsGet = true)]
        public DateTime? FromDate { get; set; }
        [BindProperty(SupportsGet = true)]
        public DateTime? ToDate { get; set; }

        public string? FromDateStr => FromDate?.ToString("yyyy-MM-dd");
        public string? ToDateStr => ToDate?.ToString("yyyy-MM-dd");

        public async Task OnGetAsync()
        {
            var query = _context.Bookings
                .Include(b => b.User)
                .Include(b => b.Court)
                .AsQueryable();

            if (!string.IsNullOrEmpty(UserName))
                query = query.Where(b => b.User.UserName.Contains(UserName));
            if (!string.IsNullOrEmpty(CourtName))
                query = query.Where(b => b.Court.Name.Contains(CourtName));
            if (!string.IsNullOrEmpty(Status) && Enum.TryParse<BookingStatus>(Status, out var bookingStatus))
                query = query.Where(b => b.Status == bookingStatus);
            if (FromDate.HasValue)
                query = query.Where(b => b.BookingDate >= DateOnly.FromDateTime(FromDate.Value));
            if (ToDate.HasValue)
                query = query.Where(b => b.BookingDate <= DateOnly.FromDateTime(ToDate.Value));

            Bookings = await query
                .OrderByDescending(b => b.BookingDate)
                .ThenByDescending(b => b.StartTime)
                .ToListAsync();
        }

        public async Task<IActionResult> OnPostConfirmAsync(int id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return NotFound();
            booking.Status = BookingStatus.Confirmed;
            await _context.SaveChangesAsync();
            return RedirectToPage();
        }

        public async Task<IActionResult> OnPostCancelAsync(int id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null) return NotFound();
            booking.Status = BookingStatus.Cancelled;
            await _context.SaveChangesAsync();
            return RedirectToPage();
        }

        public async Task<IActionResult> OnPostCompleteAsync(int id)
        {
            var booking = await _context.Bookings.Include(b => b.Court).FirstOrDefaultAsync(b => b.BookingID == id);
            if (booking == null) return NotFound();
            booking.Status = BookingStatus.Completed;
            if (booking.TotalAmount == 0 && booking.Court != null)
            {
                var hours = (booking.EndTime - booking.StartTime).TotalHours;
                booking.TotalAmount = booking.Court.Price * (decimal)hours;
            }
            await _context.SaveChangesAsync();
            return RedirectToPage();
        }

        public async Task<IActionResult> OnPostFixCompletedBookingsAsync()
        {
            var bookings = await _context.Bookings
                .Include(b => b.Court)
                .Where(b => b.Status == BookingStatus.Completed)
                .ToListAsync();

            foreach (var booking in bookings)
            {
                if (booking.Court != null)
                {
                    booking.TotalAmount = booking.Court.Price;
                }
            }
            await _context.SaveChangesAsync();
            TempData["Message"] = $"Đã cập nhật tổng tiền = giá sân cho {bookings.Count} booking hoàn thành!";
            return RedirectToPage();
        }
    }
} 