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
                    new AccountClass { accountClassId = 1, accountClassName = "Loan", accountClassCode = "loan", accountClassSortOrder = "1" },
                    new AccountClass { accountClassId = 2, accountClassName = "Creadit", accountClassCode = "Creadit class code", accountClassSortOrder = "2" },
                    new AccountClass { accountClassId = 3, accountClassName = "Cash", accountClassCode = "CA", accountClassSortOrder = "3" }
                );
            });

            modelBuilder.Entity<LoanStatus>(entity =>
            {
                entity.HasKey(e => e.statusId);
                entity.HasData(
                    new LoanStatus { statusId = 1, statusDescription = "Pending", statusCode = "PEN", isDefault = true, isActive = true, accountClassId = 1, isApplicationStatus = false, accountCount = 0 },
                    new LoanStatus { statusId = 2, statusDescription = "Active", statusCode = "ACT", isDefault = false, isActive = true, accountClassId = 2, isApplicationStatus = false, accountCount = 5 },
                    new LoanStatus { statusId = 3, statusDescription = "Application", statusCode = "APP", isDefault = false, isActive = true, accountClassId = 3, isApplicationStatus = true, accountCount = 2 }
                );
            });

            // Seed User data
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.userLogin);
                entity.HasData(
                    new User { userLogin = "jdoe", userEmail = "jdoe@example.com" },
                    new User { userLogin = "asmith", userEmail = "asmith@example.com" }
                );
            });

            // Seed Customer data
            modelBuilder.Entity<Customer>(entity =>
            {
                entity.HasKey(e => e.customerId);
                entity.HasData(
                    new Customer { customerId = "CUST001", customerName = "John Doe", bankId = "BANK001", customerBranchId = "BR001", customerNumber = "CN001", employee = false },
                    new Customer { customerId = "CUST002", customerName = "Jane Smith", bankId = "BANK001", customerBranchId = "BR002", customerNumber = "CN002", employee = true }
                );
            });

            // Seed Loan data
            modelBuilder.Entity<Loan>(entity =>
            {
                entity.HasKey(e => e.loanId);
                entity.HasData(
                    new Loan { loanId = "LOAN001", loanStatusId = 1, loanBranchId = "BR001" },
                    new Loan { loanId = "LOAN002", loanStatusId = 2, loanBranchId = "BR002" },
                    new Loan { loanId = "LOAN003", loanStatusId = 3, loanBranchId = "BR001" }
                );
            });

            // Seed DocumentType data
            modelBuilder.Entity<DocumentType>(entity =>
            {
                entity.HasKey(e => e.documentTypeId);
                entity.HasData(
                    new DocumentType { documentTypeId = 1, documentTypeName = "Identification" },
                    new DocumentType { documentTypeId = 2, documentTypeName = "Financial" }
                );
            });

            // Seed DocumentSubType data
            modelBuilder.Entity<DocumentSubType>(entity =>
            {
                entity.HasData(
                    new DocumentSubType { documentTypeId = 1, documentSubTypeId = 1, documentSubTypeName = "Driver License" },
                    new DocumentSubType { documentTypeId = 1, documentSubTypeId = 2, documentSubTypeName = "Passport" },
                    new DocumentSubType { documentTypeId = 2, documentSubTypeId = 1, documentSubTypeName = "Bank Statement" }
                );
            });

            // Seed DocumentSubTypeOption data
            modelBuilder.Entity<DocumentSubTypeOption>(entity =>
            {
                entity.HasKey(e => e.documentSubTypeId);
                entity.HasData(
                    new DocumentSubTypeOption { documentSubTypeId = 1, hasDemographicData = true },
                    new DocumentSubTypeOption { documentSubTypeId = 2, hasDemographicData = false }
                );
            });

            // Seed DocumentDefinitions data
            modelBuilder.Entity<DocumentDefinitions>(entity =>
            {
                entity.HasKey(e => e.documentDefId);
                entity.HasData(
                    new DocumentDefinitions { documentDefId = "DOCDEF001", documentTypeId = 1, documentSubTypeId = 1, hideEmployeeFileYN = "N" },
                    new DocumentDefinitions { documentDefId = "DOCDEF002", documentTypeId = 1, documentSubTypeId = 2, hideEmployeeFileYN = "Y" },
                    new DocumentDefinitions { documentDefId = "DOCDEF003", documentTypeId = 2, documentSubTypeId = 1, hideEmployeeFileYN = "N" }
                );
            });

            // Seed Document data
            modelBuilder.Entity<Document>(entity =>
            {
                entity.HasKey(e => e.documentId);
                entity.HasData(
                    new Document { documentId = "DOC001", customerId = "CUST001", loanId = "LOAN001", documentDefId = "DOCDEF001", documentStatus = 1, documentTitle = "John's Driver License", filename = "license.pdf" },
                    new Document { documentId = "DOC002", customerId = "CUST002", loanId = "LOAN002", documentDefId = "DOCDEF002", documentStatus = 1, documentTitle = "Jane's Passport", filename = "passport.pdf" },
                    new Document { documentId = "DOC003", customerId = "CUST001", loanId = null, documentDefId = "DOCDEF003", documentStatus = 2, documentTitle = "Bank Statement Jan 2024", filename = "statement.pdf" }
                );
            });

            // Seed DocumentHistory data
            modelBuilder.Entity<DocumentHistory>(entity =>
            {
                entity.HasKey(e => e.historyId);
                entity.HasData(
                    new DocumentHistory { historyId = "HIST001", documentId = "DOC001", documentType = "Identification", qcStatus = 1, qcHistory = "Approved by admin", userLogin = "jdoe" },
                    new DocumentHistory { historyId = "HIST002", documentId = "DOC002", documentType = "Identification", qcStatus = 2, qcHistory = "Needs review", userLogin = "asmith" },
                    new DocumentHistory { historyId = "HIST003", documentId = "DOC003", documentType = "Financial", qcStatus = null, qcHistory = null, userLogin = "jdoe" }
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
