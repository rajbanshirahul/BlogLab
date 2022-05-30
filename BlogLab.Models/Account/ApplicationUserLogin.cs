using System.ComponentModel.DataAnnotations;

namespace BlogLab.Models.Account
{
    public class ApplicationUserLogin
    {
        [Required(ErrorMessage = "Username is required")]
        [MinLength(5, ErrorMessage = "Must be at least 5-20 characters")]
        [MaxLength(20, ErrorMessage = "Must be at least 5-20 characters")]
        public string Username { get; set; }

        [Required(ErrorMessage = "Password is required")]
        [MinLength(8, ErrorMessage = "Must be at least 8-50 characters")]
        [MaxLength(50, ErrorMessage = "Must be at least 8-50 characters")]
        public string Password { get; set; }
    }
}
