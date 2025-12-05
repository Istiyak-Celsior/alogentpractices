function SystemSettingsDTO() {
    var self = this;

    self.SiteConnectionString              = '';
    self.ReportConnectionString            = '';
    self.ScannedImagesPath                 = '';
    self.WebSitePath                       = '';
    self.EnableWindowsSecurity             = false;
    self.EnableBranchSecurity              = false;
    self.ScannedFilesPath                  = '';
    self.ServerUrl                         = '';
    self.UploadLocalPath                   = '';
    self.UploadUnc                         = '';
    self.BaseFolder                        = '';
    self.BranchSecurityLevel               = '';
    self.DaysToKeepLogs                    = '';
    self.OverrideWorkstationOutputFormat   = false;
    self.GlobalWorkstationOutputFormat     = '';
    self.PurgeEvaluateTimeout              = '';
    self.PurgeExecuteTimeout               = '';
    self.PurgeReportTimeout                = '';
    self.EnablePurgeAdvancedOptions        = '';
    self.EnforceSimpleMode                 = false;
    self.DocumentSchedulerSqlCmdTimeout    = '';
    self.EnableAmountFilterActivation      = false;
    self.DisableRtev                       = false;
    self.ExceptionValidatorDatabaseTimeout = '';
}