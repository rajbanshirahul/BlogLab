using System.ComponentModel.DataAnnotations;

namespace BlogLab.Models.Blog
{
    public class BlogCreate
    {
        public int BlogId { get; set; }

        [Required(ErrorMessage = "Title is required")]
        [MinLength(5, ErrorMessage = "Must be 5-100 characters")]
        [MaxLength(100, ErrorMessage = "Must be 5-100 characters")]
        public string Title { get; set; }

        [Required(ErrorMessage = "Content is required")]
        [MinLength(10, ErrorMessage = "Must be 10-3000 characters")]
        [MaxLength(3000, ErrorMessage = "Must be 10-3000 characters")]
        public string Content { get; set; }
        public int? PhotoId { get; set; }
    }
}
