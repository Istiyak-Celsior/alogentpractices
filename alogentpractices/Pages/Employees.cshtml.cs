using alogentpractices.DAL;
using alogentpractices.Entities;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;

namespace alogentpractices.Pages
{
    public class EmployeesModel : PageModel
    {
        private readonly ApplicationDbContext _context;

        public EmployeesModel(ApplicationDbContext context)
        {
            _context = context;
        }

        public IList<Employee> Employee { get;set; } = default!;

        public async Task OnGetAsync()
        {
            Employee = await _context.Employees.ToListAsync();
        }
    }
}
