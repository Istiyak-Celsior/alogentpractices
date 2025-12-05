function PDFServiceTime() {
    var self = this;

    self.hh = null;
    self.mm = null;
    self.tt = null;
}

function PDFServiceSettingsDTO() {
    var self = this;

    self.IsActive                          = true;
    self.IsBackupEnabled                   = true;
    self.IsConversionEnabled               = false;
    self.IsAutomaticPageRecognitionEnabled = false;
    self.RunOnTimeframe                    = false;
    self.StartTime                         = null;
    self.EndTime                           = null;
    self.ServiceDays                       = '';
    self.BackupDirectory                   = '';
};