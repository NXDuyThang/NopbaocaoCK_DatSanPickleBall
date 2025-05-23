using DAL.Models;

namespace WebDatSanPickleBall.Models
{
    public class CourtDetailsViewModel
    {
        public Court Court { get; set; }
        public List<BookingViewModel> Bookings { get; set; }
    }

    public class BookingViewModel
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public DateTime Start { get; set; }
        public DateTime End { get; set; }
        public string Color { get; set; }
    }
} 