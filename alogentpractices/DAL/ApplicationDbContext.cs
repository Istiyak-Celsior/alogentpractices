using alogentpractices.Entities;
using Microsoft.EntityFrameworkCore;

namespace alogentpractices.DAL
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }
        public DbSet<Employee> Employees { get; set; }
        public DbSet<AccountClass> AccountClasses { get; set; }
        public DbSet<LoanStatus> LoanStatuses { get; set; }
        public DbSet<Loans> Loanses { get; set; }
        public DbSet<TaskGroupType> TaskGroupTypes { set; get; }
        public DbSet<TaskGroup> TaskGroups { set; get; }
        public DbSet<Entities.Tasks> Tasks { set; get; }
        public DbSet<Entities.Exception> Exceptions { set; get; }
        public DbSet<Bank> banks { set; get; }
        public DbSet<customerType> customerTypes { set; get; }
        public DbSet<customerTypeDescription> customerTypeDescriptions { set; get; }
        public DbSet<loanTypes> loanTypes { set; get; }
        public DbSet<documentDefinations> documentDefinations { set; get; }
        public DbSet<exceptionDefinition> exceptionDefinitions { set; get; }
        public DbSet<noticeLetterSetException> noticeLetterSetExceptions { set; get; }
        public DbSet<DocumentHistory> DocumentHistory { get; set; }
        public DbSet<Document> Document { get; set; }
        public DbSet<Customer> Customer { get; set; }
        public DbSet<Loan> Loan { get; set; }
        public DbSet<LoanStatus> LoanStatus { get; set; }
        public DbSet<AccountClass> AccountClass { get; set; }
        public DbSet<DocumentDefinitions> DocumentDefinitions { get; set; }
        public DbSet<DocumentType> DocumentType { get; set; }
        public DbSet<DocumentSubType> DocumentSubType { get; set; }
        public DbSet<DocumentSubTypeOption> DocumentSubTypeOption { get; set; }
        public DbSet<User> User { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<TaskGroupType>(entity =>
            {
                entity.HasKey(e => e.TaskGroupId);
            });

            // Configure composite key for DocumentSubType
            modelBuilder.Entity<DocumentSubType>()
                .HasKey(dst => new { dst.documentTypeId, dst.documentSubTypeId });

            modelBuilder.Entity<AccountClass>(entity =>
            {
                entity.HasKey(e => e.accountClassId);
                entity.HasData(
                    new AccountClass { accountClassId = 1, accountClassName = "Loan", accountClassCode = "loan", accountClassSortOrder = 1 }
                );
            });

            modelBuilder.Entity<LoanStatus>(entity =>
            {
                entity.HasKey(e => e.statusId);
                entity.HasData(
                    new LoanStatus { statusId = 1, statusDescription = "Pending", statusCode = "PEN", isDefault = true, isActive = true, accountClassId = 1, isApplicationStatus = false, AccountCount = 0 }
                );
            });

            modelBuilder.Entity<Employee>(entity =>
            {
                entity.HasKey(e => e.EmployeeUid);
                entity.HasData(
                    new Employee { EmployeeUid = 1, FirstName = "Amit", LastName = "Kumar", Email = "amit@gmail.com", Mobile = "8885485421" },
                    new Employee { EmployeeUid = 2, FirstName = "Sumit", LastName = "Kumar", Email = "sumit@gmail.com", Mobile = "8885485422" },
                    new Employee { EmployeeUid = 3, FirstName = "Raounak", LastName = "Saikh", Email = "rounak@gmail.com", Mobile = "8885485234" },
                    new Employee { EmployeeUid = 4, FirstName = "Khusbu", LastName = "Kumari", Email = "khusbu@gmail.com", Mobile = "8885499876" },
                    new Employee { EmployeeUid = 5, FirstName = "Anil", LastName = "Singh", Email = "anil@gmail.com", Mobile = "8978685421" },
                    new Employee { EmployeeUid = 6, FirstName = "Ali", LastName = "Md", Email = "ali@gmail.com", Mobile = "6756085421" },
                    new Employee { EmployeeUid = 7, FirstName = "Mukesh", LastName = "Anup", Email = "mukesh@gmail.com", Mobile = "5248135682" },
                    new Employee { EmployeeUid = 8, FirstName = "Rohit", LastName = "Singh", Email = "rohit@gmail.com", Mobile = "9958642035" },
                    new Employee { EmployeeUid = 9, FirstName = "Ravi", LastName = "Kumar", Email = "ravi@gmail.com", Mobile = "8824579201" }
                );
            });
        }
    }
}
