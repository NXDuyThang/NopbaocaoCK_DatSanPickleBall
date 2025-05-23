using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DAL.Models;

public class TimeSlot
{
    [Key]
    public int TimeSlotID { get; set; }

    [Required]
    public int CourtID { get; set; }

    [Required]
    public DayOfWeek DayOfWeek { get; set; }

    [Required]
    public TimeOnly StartTime { get; set; }

    [Required]
    public TimeOnly EndTime { get; set; }

    // Navigation property
    [ForeignKey("CourtID")]
    public virtual Court Court { get; set; } = null!;
} 