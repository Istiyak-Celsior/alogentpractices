using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace alogentpractices.Pages
{
    public class exceptiondefselecttypeModel : PageModel
    {
        private readonly IHttpContextAccessor _contextAccessor;

        public exceptiondefselecttypeModel(IHttpContextAccessor contextAccessor)
        {
            _contextAccessor = contextAccessor;
        }

        public void OnGet()
        {
            _contextAccessor.HttpContext.Session.SetString("permissionException", "4");
        }
    }
}
