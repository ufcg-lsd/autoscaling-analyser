import datetime
import croniter

class cr_parser:
  
  def __init__(self, cron_pattern, timestamp):
    self.cron_pattern = cron_pattern
    self.timestamp = timestamp
    self.croniterr = croniter.croniter(cron_pattern, datetime.datetime.fromtimestamp(timestamp))


  def get_next(self):
    return self.croniterr.get_next()
