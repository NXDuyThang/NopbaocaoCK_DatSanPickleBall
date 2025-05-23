using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DAL.Models;

public class Payment
{
    [Key]
    public int PaymentID { get; set; }

    [Required]
    public int BookingID { get; set; }

    [Required]
    [Column(TypeName = "decimal(18,2)")]
    public decimal Amount { get; set; }

    [Required]
    [StringLength(50)]
    public string PaymentMethod { get; set; } = null!; // Momo, ZaloPay, BankTransfer, etc.

    [Required]
    [StringLength(20)]
    public string PaymentStatus { get; set; } = "Pending"; // Pending, Completed, Failed, Refunded

    public DateTime TransactionDate { get; set; } = DateTime.UtcNow;

    // Navigation property
    [ForeignKey("BookingID")]
    public virtual Booking Booking { get; set; } = null!;
} 