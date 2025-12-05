using alogentpractices.DAL;
using Microsoft.EntityFrameworkCore;

namespace alogentpractices.Services
{
    public class AccountStatusListService
    {
        private readonly ApplicationDbContext _context;

        public AccountStatusListService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<dynamic>> LoadAccountStatus(int accountClassId)
        {
            var result = (from ac in _context.AccountClasses
                          join ls in _context.LoanStatuses
                              on ac.accountClassId equals ls.accountClassId into gj
                          from ls in gj.DefaultIfEmpty()
                          where ac.accountClassId == accountClassId && 
                          (ls.isApplicationStatus == false || ls.isApplicationStatus == null)
                          orderby ac.accountClassSortOrder, ls.statusDescription
                          select new
                          {
                              ac.accountClassId,
                              ac.accountClassName,
                              ac.accountClassCode,
                              ls.statusId,
                              ls.statusDescription,
                              ls.statusCode,
                              ls.isDefault,
                              ls.isActive,
                              ls.isApplicationStatus,
                              ls.isActiveApplicationStatus,
                              ls.isApprovedApplicationStatus,
                              ls.isDefaultApplicationStatus,
                              AccountCount = _context.Loanses.Count(l => l.LoanStatusId == ls.statusId)
                          }).ToList<dynamic>();

            return await Task.FromResult(result);
        }
    }
}
