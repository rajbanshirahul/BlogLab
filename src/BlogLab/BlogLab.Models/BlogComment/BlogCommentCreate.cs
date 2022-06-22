using System.ComponentModel.DataAnnotations;

namespace BlogLab.Models.BlogComment
{
    public class BlogCommentCreate
    {
        public int BlogCommentId { get; set; }
        public int? ParentBlogCommentId { get; set; }
        public int BlogId { get; set; }

        [Required(ErrorMessage = "Content is required")]
        [MinLength(1, ErrorMessage = "Must be 1-500 characters")]
        [MaxLength(5, ErrorMessage = "Must be 1-500 characters")]
        public string Content { get; set; }
    }
}
