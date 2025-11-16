// PoopyPals Analytics Agent
// Handles queries about logs, streaks, and statistics

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface AnalyticsRequest {
  device_id: string
  query: string
  tool?: string
  params?: Record<string, any>
}

interface ToolResult {
  success: boolean
  data?: any
  error?: string
  message?: string
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Parse request
    const { device_id, query, tool, params }: AnalyticsRequest = await req.json()

    if (!device_id) {
      return new Response(
        JSON.stringify({ error: 'device_id is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client with service role for RLS bypass in Edge Function
    // RLS is still enforced by passing device_id to all queries
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Route to appropriate tool
    let result: ToolResult

    if (tool) {
      // Direct tool call (when orchestrator already determined which tool)
      result = await executeTool(supabase, device_id, tool, params || {})
    } else {
      // Analyze natural language query and execute
      result = await analyzeAndExecute(supabase, device_id, query)
    }

    return new Response(
      JSON.stringify(result),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Analytics Agent Error:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || 'Internal server error'
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// Analyze query and execute appropriate tool
async function analyzeAndExecute(
  supabase: any,
  device_id: string,
  query: string
): Promise<ToolResult> {
  const queryLower = query.toLowerCase()

  // Pattern matching for common queries
  if (queryLower.includes('streak')) {
    return await executeTool(supabase, device_id, 'calculate_streak', {})
  }

  if (queryLower.includes('today')) {
    return await executeTool(supabase, device_id, 'fetch_logs', {
      start_date: new Date().toISOString().split('T')[0],
      end_date: new Date().toISOString().split('T')[0]
    })
  }

  if (queryLower.includes('this week') || queryLower.includes('past week')) {
    const endDate = new Date()
    const startDate = new Date()
    startDate.setDate(endDate.getDate() - 7)

    return await executeTool(supabase, device_id, 'fetch_logs', {
      start_date: startDate.toISOString().split('T')[0],
      end_date: endDate.toISOString().split('T')[0]
    })
  }

  if (queryLower.includes('average') || queryLower.includes('avg')) {
    if (queryLower.includes('time') || queryLower.includes('duration')) {
      return await executeTool(supabase, device_id, 'get_stats', { metric: 'avg_duration' })
    }
  }

  if (queryLower.includes('total') || queryLower.includes('how many')) {
    return await executeTool(supabase, device_id, 'get_stats', { metric: 'total_logs' })
  }

  if (queryLower.includes('yesterday')) {
    const yesterday = new Date()
    yesterday.setDate(yesterday.getDate() - 1)
    const dateStr = yesterday.toISOString().split('T')[0]

    return await executeTool(supabase, device_id, 'fetch_logs', {
      start_date: dateStr,
      end_date: dateStr
    })
  }

  // Default: return general stats
  return await executeTool(supabase, device_id, 'get_stats', { metric: 'summary' })
}

// Execute specific tool
async function executeTool(
  supabase: any,
  device_id: string,
  tool: string,
  params: Record<string, any>
): Promise<ToolResult> {
  switch (tool) {
    case 'calculate_streak':
      return await calculateStreak(supabase, device_id)

    case 'fetch_logs':
      return await fetchLogs(supabase, device_id, params)

    case 'get_stats':
      return await getStats(supabase, device_id, params.metric || 'summary')

    default:
      return {
        success: false,
        error: `Unknown tool: ${tool}`
      }
  }
}

// Tool: Calculate Streak
async function calculateStreak(supabase: any, device_id: string): Promise<ToolResult> {
  try {
    // Call stored procedure
    const { data, error } = await supabase.rpc('calculate_streak', {
      p_device_id: device_id
    })

    if (error) throw error

    const streak = data || 0
    const emoji = streak >= 7 ? '🔥' : streak >= 3 ? '⚡' : '✨'

    return {
      success: true,
      data: { streak },
      message: streak > 0
        ? `You're on a ${streak}-day streak! ${emoji}`
        : "Start your streak today!"
    }
  } catch (error) {
    console.error('Calculate Streak Error:', error)
    return {
      success: false,
      error: 'Failed to calculate streak'
    }
  }
}

// Tool: Fetch Logs
async function fetchLogs(
  supabase: any,
  device_id: string,
  params: { start_date?: string; end_date?: string; rating?: string; limit?: number }
): Promise<ToolResult> {
  try {
    let query = supabase
      .from('poop_logs')
      .select('*')
      .eq('device_id', device_id)
      .eq('is_deleted', false)
      .order('logged_at', { ascending: false })

    // Apply filters
    if (params.start_date) {
      query = query.gte('logged_at', `${params.start_date}T00:00:00`)
    }
    if (params.end_date) {
      query = query.lte('logged_at', `${params.end_date}T23:59:59`)
    }
    if (params.rating) {
      query = query.eq('rating', params.rating)
    }
    if (params.limit) {
      query = query.limit(params.limit)
    }

    const { data, error } = await query

    if (error) throw error

    return {
      success: true,
      data: {
        logs: data,
        count: data.length
      },
      message: data.length > 0
        ? `Found ${data.length} log${data.length === 1 ? '' : 's'}`
        : 'No logs found for this period'
    }
  } catch (error) {
    console.error('Fetch Logs Error:', error)
    return {
      success: false,
      error: 'Failed to fetch logs'
    }
  }
}

// Tool: Get Statistics
async function getStats(
  supabase: any,
  device_id: string,
  metric: string
): Promise<ToolResult> {
  try {
    const { data: logs, error } = await supabase
      .from('poop_logs')
      .select('duration_seconds, rating, consistency, logged_at')
      .eq('device_id', device_id)
      .eq('is_deleted', false)

    if (error) throw error

    if (logs.length === 0) {
      return {
        success: true,
        data: { message: 'No logs yet. Start tracking!' },
        message: 'No data available'
      }
    }

    const stats: Record<string, any> = {}

    // Total logs
    stats.total_logs = logs.length

    // Average duration
    const durations = logs.map((l: any) => l.duration_seconds).filter(Boolean)
    if (durations.length > 0) {
      const avgSeconds = durations.reduce((a: number, b: number) => a + b, 0) / durations.length
      stats.avg_duration = Math.round(avgSeconds)
      stats.avg_duration_formatted = formatDuration(stats.avg_duration)
    }

    // Rating distribution
    const ratingCounts: Record<string, number> = {}
    logs.forEach((log: any) => {
      ratingCounts[log.rating] = (ratingCounts[log.rating] || 0) + 1
    })
    stats.rating_distribution = ratingCounts

    // Most common rating
    const mostCommonRating = Object.entries(ratingCounts)
      .sort(([, a], [, b]) => (b as number) - (a as number))[0]
    stats.most_common_rating = mostCommonRating ? mostCommonRating[0] : null

    // Return specific metric or summary
    if (metric === 'avg_duration') {
      return {
        success: true,
        data: {
          avg_duration: stats.avg_duration,
          avg_duration_formatted: stats.avg_duration_formatted
        },
        message: `Your average bathroom time is ${stats.avg_duration_formatted}`
      }
    }

    if (metric === 'total_logs') {
      return {
        success: true,
        data: { total_logs: stats.total_logs },
        message: `You have ${stats.total_logs} total log${stats.total_logs === 1 ? '' : 's'}`
      }
    }

    // Summary
    return {
      success: true,
      data: stats,
      message: `You have ${stats.total_logs} logs with an average duration of ${stats.avg_duration_formatted}`
    }

  } catch (error) {
    console.error('Get Stats Error:', error)
    return {
      success: false,
      error: 'Failed to get statistics'
    }
  }
}

// Helper: Format duration
function formatDuration(seconds: number): string {
  if (seconds < 60) {
    return `${seconds} seconds`
  }
  const minutes = Math.floor(seconds / 60)
  const remainingSeconds = seconds % 60
  if (remainingSeconds === 0) {
    return `${minutes} minute${minutes === 1 ? '' : 's'}`
  }
  return `${minutes}m ${remainingSeconds}s`
}
