using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DAL.Models;

public class Notification
{
    [Key]
    public int NotificationID { get; set; }

    [Required]
    public string UserID { get; set; } = null!;

    [Required]
    [StringLength(500)]
    public string Message { get; set; } = null!;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public bool IsRead { get; set; } = false;

    // Navigation property
    [ForeignKey("UserID")]
    public virtual User User { get; set; } = null!;
} 