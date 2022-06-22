using BlogLab.Models.Photo;
using Dapper;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace BlogLab.Repository
{
    public class PhotoRepository : IPhotoRepository
    {
        private readonly IConfiguration _config;

        public PhotoRepository(IConfiguration config)
        {
            _config = config;
        }
        public async Task<int> DeleteAsync(int photoId)
        {
            await using var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection"));
            await connection.OpenAsync();

            int affectedRows = await connection
                .ExecuteAsync("Photo_Delete", new { PhotoId = photoId }, commandType: CommandType.StoredProcedure);
            return affectedRows;
        }

        public async Task<List<Photo>> GetAllByUserIdAsync(int applicationUserId)
        {
            await using var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection"));
            await connection.OpenAsync();

            var photos = await connection
                .QueryAsync<Photo>("Photo_GetByUserId", new { ApplicationUserId = applicationUserId }, commandType: CommandType.StoredProcedure);

            return photos.ToList();
        }

        public async Task<Photo> GetAsync(int photoId)
        {
            await using var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection"));
            await connection.OpenAsync();

            var photo = await connection.QueryFirstOrDefaultAsync<Photo>(
                "Photo_Get",
                new { PhotoId = photoId },
                commandType: CommandType.StoredProcedure);

            return photo;
        }

        public async Task<Photo> InsertAsync(PhotoCreate photoCreate, int applicationUserId)
        {
            var dataTable = new DataTable();
            dataTable.Columns.Add("PublicId", typeof(string));
            dataTable.Columns.Add("ImageUrl", typeof(string));
            dataTable.Columns.Add("Description", typeof(string));

            dataTable.Rows.Add(photoCreate.PublicId, photoCreate.ImageUrl, photoCreate.Description);

            await using var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection"));
            await connection.OpenAsync();

            var photoIdNew = await connection.ExecuteScalarAsync<int>(
                "Photo_Insert",
                new { Photo = dataTable.AsTableValuedParameter("dbo.PhotoType") },
                commandType: CommandType.StoredProcedure);

            return await GetAsync(photoIdNew);
        }
    }
}
