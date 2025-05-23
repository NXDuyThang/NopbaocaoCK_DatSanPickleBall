using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DAL.Models;

public class Review
{
    [Key]
    public int ReviewID { get; set; }

    [Required]
    public string UserID { get; set; } = null!;

    [Required]
    public int CourtID { get; set; }

    [Required]
    [Range(1, 5)]
    public int Rating { get; set; }

    [StringLength(1000)]
    public string? Comment { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    [ForeignKey("UserID")]
    public virtual User User { get; set; } = null!;

    [ForeignKey("CourtID")]
    public virtual Court Court { get; set; } = null!;
} 