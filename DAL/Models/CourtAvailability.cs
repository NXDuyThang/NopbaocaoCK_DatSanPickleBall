using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DAL.Models;

public class CourtAvailability
{
    [Key]
    public int AvailabilityID { get; set; }

    [Required]
    public int CourtID { get; set; }

    [Required]
    public DateOnly Date { get; set; }

    [Required]
    public bool IsAvailable { get; set; } = true;

    [StringLength(500)]
    public string? Note { get; set; }

    // Navigation property
    [ForeignKey("CourtID")]
    public virtual Court Court { get; set; } = null!;
} 