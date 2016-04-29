'''
Postgres mixins
'''
from sqlalchemy import Column, Integer, String, Float
from sqlalchemy.dialects.postgresql import ARRAY
from contextlib import contextmanager

class StatusTypeMixin(object):
    """ Gather information about processing status """
    id           = Column(Integer, primary_key=True)
    case_id      = Column(String)
    vcf_id       = Column(String)
    src_vcf_id   = Column(String)
    files        = Column(ARRAY(String))
    status       = Column(String)
    location     = Column(String)
    datetime_now = Column(String)
    md5          = Column(String)

    def __repr__(self):
        return "<StatusTypeMixin(case_id='%s', status='%s' , location='%s'>" %(self.case_id,
                self.status, self.location)

class TimeTypeMixin(object):
    ''' Gather timing metrics with input/output uuids '''
    id           = Column(Integer, primary_key=True)
    case_id      = Column(String)
    datetime_now = Column(String)
    vcf_id       = Column(String)
    src_vcf_id   = Column(String)
    files        = Column(ARRAY(String))
    elapsed      = Column(String)
    thread_count = Column(String)
    status       = Column(String)

    def __repr__(self):
        return "<TimeToolTypeMixin(case_id='%s', elapsed='%s', status='%s'>" %(self.case_id,
                self.elapsed, self.status)

class ToolTypeMixin(object):
    """ Gather the timing metrics for different datasets """

    id           = Column(Integer, primary_key=True)
    case_id      = Column(String)
    datetime_now = Column(String)
    vcf_id       = Column(String)
    files        = Column(ARRAY(String))
    elapsed      = Column(String)
    thread_count = Column(String)
    status       = Column(String)

    def __repr__(self):
        return "<ToolTypeMixin(systime='%d', usertime='%d', elapsed='%s', cpu='%d', max_resident_time='%d'>" %(self.systime,
                self.usertime, self.elapsed, self.cpu, self.max_resident_time)
