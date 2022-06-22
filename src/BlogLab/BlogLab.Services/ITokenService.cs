using BlogLab.Models.Account;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BlogLab.Services
{
    public interface ITokenService
    {
        public string CreateJwtToken(ApplicationUserIdentity user);
    }
}
