using System.ComponentModel.DataAnnotations;

namespace BlogLab.Models.Account
{
    public class ApplicationUserCreate : ApplicationUserLogin
    {
        [MinLength(3, ErrorMessage = "Must be at least 3 characters")]
        [MaxLength(100, ErrorMessage = "Must be 3-100 characters")]
        public string Fullname { get; set; }

        [EmailAddress]
        [MaxLength(50, ErrorMessage = "Can be at most to 50 characters")]
        public string Email { get; set; }
    }
}
