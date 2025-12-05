using alogentpractices.DAL;

namespace alogentpractices.Entities
{
    public class SeedData
    {
        public static void PreConfiguraData(ApplicationDbContext context)
        {
            context.customerTypes.AddRange(
                new customerType { customerTypeId = 1, customerTypeDescription = "Retail" },
                new customerType { customerTypeId = 2, customerTypeDescription = "Corporate" },
                new customerType { customerTypeId = 3, customerTypeDescription = "SME" },
                new customerType { customerTypeId = 4, customerTypeDescription = "VIP" },
                new customerType { customerTypeId = 5, customerTypeDescription = "Online Only" }
            );

            // Seed CustomerTypeDescriptions
            context.customerTypeDescriptions.AddRange(
                new customerTypeDescription { customerTypeDescriptionId = 1, customerTypeId = 1, bankId = "1" },
                new customerTypeDescription { customerTypeDescriptionId = 2, customerTypeId = 2, bankId = "1" },
                new customerTypeDescription { customerTypeDescriptionId = 3, customerTypeId = 3, bankId = "1" },
                new customerTypeDescription { customerTypeDescriptionId = 4, customerTypeId = 4, bankId = "1" },
                new customerTypeDescription { customerTypeDescriptionId = 5, customerTypeId = 5, bankId = "1" }
            );


            if (!context.banks.Any())
            {
                context.banks.AddRange(
                    new Bank
                    {
                        bankId = "1",
                        bankName = "Bank of America"
                    }
                );
            }


            if (!context.loanTypes.Any())
            {
                context.loanTypes.AddRange(
                    new loanTypes { loanTypeId = 1, loanTypeDescription = "Home Loan", accountClassId = 3 },
                    new loanTypes { loanTypeId = 2, loanTypeDescription = "Car Loan", accountClassId = 3 },
                    new loanTypes { loanTypeId = 3, loanTypeDescription = "Education Loan", accountClassId = 3 },
                    new loanTypes { loanTypeId = 4, loanTypeDescription = "Gold Loan", accountClassId = 4 },
                    new loanTypes { loanTypeId = 5, loanTypeDescription = "Personal Loan", accountClassId = 4 }
                );
            }

            if (!context.documentDefinations.Any())
            {
                context.documentDefinations.AddRange(
                    new documentDefinations { documentDefinationId = 1, loanTypeId = 1, bankId = "1" },
                    new documentDefinations { documentDefinationId = 2, loanTypeId = 2, bankId = "1" },
                    new documentDefinations { documentDefinationId = 3, loanTypeId = 3, bankId = "1" },
                    new documentDefinations { documentDefinationId = 4, loanTypeId = 4, bankId = "1" },
                    new documentDefinations { documentDefinationId = 5, loanTypeId = 5, bankId = "1" }
                );
            }

            context.exceptionDefinitions.AddRange(
                new exceptionDefinition { exceptionDefId = 1, bankId = "1", exceptionDefType = "type1", sortOrder = "1", exceptionDefName = "Def A", targetTypeId = 101, weight = 10, PolicyId = "123" },
                new exceptionDefinition { exceptionDefId = 2, bankId = "1", exceptionDefType = "type2", sortOrder = "2", exceptionDefName = "Def B", targetTypeId = 102, weight = 10, PolicyId = "123" },
                new exceptionDefinition { exceptionDefId = 3, bankId = "1", exceptionDefType = "type3", sortOrder = "3", exceptionDefName = "Def C", targetTypeId = 103, weight = 10, PolicyId = "123" },
                new exceptionDefinition { exceptionDefId = 4, bankId = "1", exceptionDefType = "type4", sortOrder = "4", exceptionDefName = "Def D", targetTypeId = 104, weight = 10, PolicyId = "123" },
                new exceptionDefinition { exceptionDefId = 5, bankId = "1", exceptionDefType = "type5", sortOrder = "5", exceptionDefName = "Def E", targetTypeId = 105, weight = 10, PolicyId = "123" }
            );

            context.noticeLetterSetExceptions.AddRange(
                new noticeLetterSetException { noticeLetterSetExceptionId = "201", exceptionDefinitionId = 1 },
                new noticeLetterSetException { noticeLetterSetExceptionId = "202", exceptionDefinitionId = 2 },
                new noticeLetterSetException { noticeLetterSetExceptionId = "203", exceptionDefinitionId = 3 }
            );


            if (!context.Tasks.Any())
            {
                context.Tasks.AddRange(
                    new Tasks
                    {
                        enableNotification = false,
                        ProcessOrder = "Tsst",
                        taskGroupId = 1,
                        taskId = 1,
                        TaskLabel = "Credit",
                        transferableByUser = false
                    }
                );
            }

            if (!context.TaskGroups.Any())
            {
                context.TaskGroups.AddRange(
                    new TaskGroup
                    {
                        taskGroupId = 1,
                        taskGroupType = "C",
                        taskGroupLabel = "Credit Task",
                        bankId = "1",
                        taskCount = 2,
                        exceptionCount = 2,
                        TaskProcessing = "Execute Task in Order"
                    },
                    new TaskGroup
                    {
                        taskGroupId = 2,
                        taskGroupType = "L",
                        taskGroupLabel = "Account Task Group",
                        bankId = "1",
                        taskCount = 2,
                        exceptionCount = 2,
                        TaskProcessing = "Execute all Task"
                    },
                    new TaskGroup
                    {
                        taskGroupId = 3,
                        taskGroupType = "L",
                        taskGroupLabel = "Filling Task group",
                        bankId = "1",
                        taskCount = 2,
                        exceptionCount = 2,
                        TaskProcessing = "Execute all Task"
                    }
                );
            }

            if (!context.TaskGroupTypes.Any())
            {
                context.TaskGroupTypes.AddRange(
                    new TaskGroupType
                    {
                        TaskGroupId = 1,
                        TaskGroupLabel = "Credit Task",
                        TaskProcessing = "C",
                        TaskCount = 5,
                        ExceptionCount = 2
                    },
                    new TaskGroupType
                    {
                        TaskGroupId = 2,
                        TaskGroupLabel = "Loan Task",
                        TaskProcessing = "L",
                        TaskCount = 10,
                        ExceptionCount = 1
                    }
                );
            }


            if (!context.AccountClasses.Any())
            {
                context.AccountClasses.AddRange(
                    new AccountClass { accountClassId = 1, accountClassName = "LOAN", accountClassCode = "CTG", accountClassSortOrder = 1 },
                    new AccountClass { accountClassId = 2, accountClassName = "DEPOSIT", accountClassCode = "ATG", accountClassSortOrder = 2 },
                    new AccountClass { accountClassId = 3, accountClassName = "TRUST", accountClassCode = "trust", accountClassSortOrder = 2 },
                    new AccountClass { accountClassId = 4, accountClassName = "CREDIT", accountClassCode = "credit", accountClassSortOrder = 2 }
                );

                context.SaveChanges();
            }

            if (!context.LoanStatuses.Any())
            {
                context.LoanStatuses.AddRange(
                    new LoanStatus { statusId = 1, statusDescription = "Pending", statusCode = "PEN", isDefault = true, isActive = true, accountClassId = 1, isApplicationStatus = false, AccountCount = 0 },
                    new LoanStatus { statusId = 2, statusDescription = "Completed", statusCode = "COM", isDefault = true, isActive = true, accountClassId = 2, isApplicationStatus = false, AccountCount = 0 }
                );

                context.SaveChanges();
            }

            if (!context.Employees.Any())
            {
                context.Employees.AddRange(
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

                context.SaveChanges();
            }
        }
    }
}
