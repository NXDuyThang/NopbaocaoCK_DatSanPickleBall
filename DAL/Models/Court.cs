using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace DAL.Models;

public class Court
{
    [Key]
    [Column("CourtID")]
    public int Id { get; set; }

    [Required(ErrorMessage = "Tên sân không được để trống")]
    [Display(Name = "Tên sân")]
    [StringLength(100)]
    public string Name { get; set; } = null!;

    [Required(ErrorMessage = "Loại sân không được để trống")]
    [Display(Name = "Loại sân")]
    [Column("CourtType")]
    [StringLength(20)]
    public string Type { get; set; } = null!; // Indoor/Outdoor

    [Required(ErrorMessage = "Vị trí sân không được để trống")]
    [Display(Name = "Vị trí sân")]
    [StringLength(200)]
    public string Location { get; set; } = null!;

    [Required(ErrorMessage = "Giá sân không được để trống")]
    [Display(Name = "Giá sân (VNĐ/giờ)")]
    [Column("HourlyRate")]
    [Range(0, double.MaxValue, ErrorMessage = "Giá sân phải lớn hơn 0")]
    [Precision(18, 2)]
    public decimal Price { get; set; }

    [Display(Name = "Mô tả")]
    [StringLength(1000)]
    public string? Description { get; set; }

    [Display(Name = "Trạng thái")]
    [Column("Status")]
    public bool IsActive { get; set; } = true;

    [Display(Name = "Ngày tạo")]
    [Column("CreatedAt")]
    public DateTime CreatedAt { get; set; }

    // Navigation properties
    public ICollection<Booking>? Bookings { get; set; }
} 