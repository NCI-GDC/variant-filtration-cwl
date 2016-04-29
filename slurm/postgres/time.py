import postgres.mixins
import postgres.utils

class Time(postgres.mixins.TimeTypeMixin, postgres.utils.Base):

    __tablename__ = 'fpfilter_cwl_metrics'
