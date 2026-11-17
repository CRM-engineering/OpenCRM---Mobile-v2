# OpenCRM Mobile Architecture

Flutter UI

↓

Services

↓

SuiteCRM Client

↓

QuickCRM REST API

↓

SuiteCRM


Project Structure

lib/

app/

config/

models/

screens/

services/

widgets/

utils/


Rules

• UI never calls HTTP directly.
• All HTTP requests go through SuiteCRMClient.
• Services contain business logic.
• Models represent CRM objects.
• Widgets remain reusable.