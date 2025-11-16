# PoopyPals AI Agents - User-Facing Conversational AI

## Overview

PoopyPals includes conversational AI agents that let users ask natural language questions about their bathroom data. Powered by Supabase Edge Functions with pattern matching and data queries.

## Architecture

```
iOS App (ChatView)
    ↓
AIAgentService
    ↓
Supabase Edge Function: analytics-agent
    ↓
Pattern Matching + Tool Execution
    ↓
PostgreSQL Database (RLS enforced)
    ↓
Response with data + message
```

## Available Agents

### Analytics Agent
**Endpoint**: `analytics-agent`

**Handles**:
- Streak queries: "What's my streak?"
- Log counts: "How many times did I log this week?"
- Time-based queries: "Show me yesterday's logs"
- Statistics: "What's my average bathroom time?"

**Tools**:
1. `calculate_streak` - Current streak count
2. `fetch_logs` - Filtered log retrieval
3. `get_stats` - Aggregated statistics

## Example Queries

| Query | Tool Used | Response |
|-------|-----------|----------|
| "What's my streak?" | `calculate_streak` | "You're on a 7-day streak! 🔥" |
| "How many logs this week?" | `fetch_logs` | "Found 12 logs" |
| "Average bathroom time?" | `get_stats` | "Your average bathroom time is 2m 15s" |
| "Show me yesterday" | `fetch_logs` | Returns logs from yesterday |
| "Total logs" | `get_stats` | "You have 156 total logs" |

## Deployment

### 1. Deploy Edge Function

```bash
# From project root
cd supabase/functions

# Deploy analytics agent
supabase functions deploy analytics-agent

# Verify deployment
supabase functions list
```

### 2. Test Locally

```bash
# Serve locally
supabase functions serve analytics-agent

# Test with curl
curl -X POST http://localhost:54321/functions/v1/analytics-agent \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{
    "device_id": "00000000-0000-0000-0000-000000000000",
    "query": "What is my streak?"
  }'
```

### 3. iOS Integration

Add to your navigation:

```swift
// In HomeView or tab bar
NavigationLink(destination: ChatView()) {
    Label("Ask AI", systemImage: "message.fill")
}
```

## Security

### RLS Enforcement
All queries use device-based RLS:
```typescript
// Edge Function sets device_id context
.eq('device_id', device_id)

// RLS policy ensures isolation
CREATE POLICY "Device isolation"
ON poop_logs FOR ALL
USING (device_id = current_setting('app.device_id'));
```

### Rate Limiting
- Built into Supabase Edge Functions
- 100 requests/minute per device (default)

### Data Privacy
- No logs stored by Edge Function
- All data scoped to device_id
- No PII collection

## Pattern Matching Logic

Simple keyword matching for MVP:

```typescript
// Streak
if (query.includes('streak')) → calculate_streak

// Time periods
if (query.includes('today')) → fetch_logs(today)
if (query.includes('this week')) → fetch_logs(7 days)
if (query.includes('yesterday')) → fetch_logs(yesterday)

// Stats
if (query.includes('average')) → get_stats('avg_duration')
if (query.includes('total')) → get_stats('total_logs')
```

## Response Format

All agents return:
```json
{
  "success": true,
  "data": {
    "streak": 7
  },
  "message": "You're on a 7-day streak! 🔥"
}
```

Error format:
```json
{
  "success": false,
  "error": "Failed to calculate streak"
}
```

## iOS Service Usage

```swift
// Initialize service
let aiService = AIAgentService()

// Query with natural language
let response = try await aiService.queryAnalytics(
    query: "What's my streak?",
    deviceId: deviceId
)

// Or call specific tool
let streak = try await aiService.getStreak(deviceId: deviceId)
```

## Future Enhancements

### Phase 2: Claude API Integration
Replace pattern matching with Claude for:
- Intent classification
- Natural language understanding
- Multi-turn conversations
- Context retention

### Phase 3: More Agents
- **Insights Agent**: Pattern detection ("You log more in the morning")
- **Achievement Advisor**: Progress tracking ("3 logs until Century Club!")
- **Challenge Agent**: Daily challenge suggestions

### Phase 4: Voice Interface
- Siri Shortcuts integration
- Voice-to-text queries
- Audio responses

## Monitoring

### Edge Function Logs
```bash
# View recent logs
supabase functions logs analytics-agent

# Stream live logs
supabase functions logs analytics-agent --follow
```

### Metrics to Track
- Query success rate
- Average response time
- Most common queries
- Error frequency

## Troubleshooting

### "device_id is required" Error
**Cause**: Missing device_id in request
**Fix**: Ensure AIAgentService passes deviceId

### "Failed to calculate streak" Error
**Cause**: Database function doesn't exist
**Fix**: Run migration: `docs/supabase-migrations/05_helper_functions.sql`

### "Invalid response" Error
**Cause**: Response format mismatch
**Fix**: Update AIAgentService response parsing

## Cost Estimate

With Supabase free tier:
- Edge Function invocations: 500K/month (free)
- Database queries: Unlimited (within free tier)
- Estimated cost for 1000 users: $0/month

With Claude API (Phase 2):
- Claude API: ~$0.01 per query
- Estimated cost for 1000 users (10 queries/day): ~$300/month

## Development Workflow

1. **Add new tool**:
   - Add function in `analytics-agent/index.ts`
   - Add method in `AIAgentService.swift`
   - Test locally

2. **Update pattern matching**:
   - Edit `analyzeAndExecute()` in Edge Function
   - Add test queries
   - Deploy

3. **Deploy**:
   ```bash
   supabase functions deploy analytics-agent
   ```

4. **Test in iOS**:
   - Open ChatView
   - Try new query
   - Verify response

---

**Last Updated**: 2025-11-16
**Version**: 1.0.0 (Analytics Agent MVP)
