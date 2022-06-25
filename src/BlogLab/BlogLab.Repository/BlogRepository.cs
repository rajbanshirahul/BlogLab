﻿using BlogLab.Models.Blog;
using Dapper;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace BlogLab.Repository
{
    public class BlogRepository : IBlogRepository
    {
        private readonly IConfiguration _config;

        public BlogRepository(IConfiguration config)
        {
            _config = config;
        }

        public async Task<int> DeleteAsync(int blogId)
        {
            await using var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection"));
            await connection.OpenAsync();

            var affedtedRows = await connection.ExecuteAsync("Blog_Delete",
                new { BlogId = blogId },
                commandType: CommandType.StoredProcedure);

            return affedtedRows;
        }

        public async Task<PagedResults<Blog>> GetAllAsync(BlogPaging blogPaging)
        {
            var results = new PagedResults<Blog>();

            await using ( var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection")))
            {
                await connection.OpenAsync();

                using var multi = await connection.QueryMultipleAsync(
                    "Blog_GetAll",
                    new { Offset = (blogPaging.Page - 1) * blogPaging.PageSize, blogPaging.PageSize },
                    commandType: CommandType.StoredProcedure);

                results.Items = await multi.ReadAsync<Blog>();
                results.TotalCount = await multi.ReadFirstAsync<int>();
            };
            
            return results;
        }

        public async Task<List<Blog>> GetAllByUserIdAsync(int applicationUserId)
        {
            await using var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection"));
            await connection.OpenAsync();

            var blogs = await connection.QueryAsync<Blog>(
                "Blog_GetByUserId",
                new { ApplicationUserId = applicationUserId },
                commandType: CommandType.StoredProcedure);

            return blogs.ToList();
        }

        public async Task<List<Blog>> GetAllFamousAsync()
        {
            await using var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection"));
            await connection.OpenAsync();

            var famousBlogs = await connection.QueryAsync<Blog>(
                "Blog_GetAllFamous",
                new {},
                commandType: CommandType.StoredProcedure);
            
            return famousBlogs.ToList();
        }

        public async Task<Blog> GetAsync(int blogId)
        {
            await using var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection"));
            await connection.OpenAsync();

            var blog = await connection.QueryFirstOrDefaultAsync<Blog>(
                "Blog_Get",
                new { BlogId = blogId },
                commandType: CommandType.StoredProcedure);

            return blog;
        }

        public async Task<Blog> UpsertAsync(BlogCreate blogCreate, int applicationUserId)
        {
            var dataTable = new DataTable();
            dataTable.Columns.Add("BlodId", typeof(int));
            dataTable.Columns.Add("Title", typeof(string));
            dataTable.Columns.Add("Content", typeof(string));
            dataTable.Columns.Add("PhotoId", typeof(int));

            dataTable.Rows.Add(blogCreate.BlogId, blogCreate.Title, blogCreate.Content, blogCreate.PhotoId);

            await using var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection"));
            await connection.OpenAsync();

            int? newBlogId = await connection.ExecuteScalarAsync<int?>(
                "Blog_Upsert",
                new { Blog = dataTable.AsTableValuedParameter("dbo.BlogType"), ApplicationUserId = applicationUserId },
                commandType: CommandType.StoredProcedure);

            newBlogId ??= blogCreate.BlogId;

            return await GetAsync(newBlogId.Value);
        }
    }
}
