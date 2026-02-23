import React, { useState } from 'react';
import { Calendar, CheckCircle2, Circle, TrendingUp, Users, Target, Zap, Plus, BarChart3, Flame, Award, Clock } from 'lucide-react';

export default function PredictableRevenueApp() {
  const [activeView, setActiveView] = useState('today');
  const [showAddTask, setShowAddTask] = useState(false);
  const [showInvite, setShowInvite] = useState(false);
  const [showProfile, setShowProfile] = useState(false);
  const [showAddCategory, setShowAddCategory] = useState(false);
  const [customCategories, setCustomCategories] = useState([]);
  const [tasks, setTasks] = useState([
    { id: 1, title: 'Send 50 Cold Emails', category: 'Cold Outreach', priority: 'high', completed: false, streak: 12, type: 'Spear', time: '9:00 AM' },
    { id: 2, title: 'LinkedIn Touches - 20 Prospects', category: 'Cold Outreach', priority: 'high', completed: false, streak: 8, type: 'Spear', time: '10:30 AM' },
    { id: 3, title: 'Call Block - 30 Dials', category: 'Follow-ups', priority: 'high', completed: true, streak: 15, type: 'Spear', time: '2:00 PM' },
    { id: 4, title: 'Pipeline Review & Update CRM', category: 'Reporting', priority: 'medium', completed: false, streak: 20, type: 'Net', time: '4:00 PM' },
    { id: 5, title: 'Follow-up: 10 Warm Leads', category: 'Follow-ups', priority: 'medium', completed: true, streak: 6, type: 'Seed', time: '11:00 AM' },
  ]);

  const teamMembers = [
    { name: 'Sarah Chen', role: 'SDR', completion: 94, streak: 15, avatar: '🎯' },
    { name: 'Marcus Reid', role: 'SDR', completion: 87, streak: 12, avatar: '⚡' },
    { name: 'Alex Kim', role: 'AE', completion: 82, streak: 8, avatar: '🚀' },
    { name: 'Jordan Mills', role: 'SDR', completion: 76, streak: 5, avatar: '💪' },
  ];

  const toggleTask = (id) => {
    setTasks(tasks.map(task => 
      task.id === id ? { ...task, completed: !task.completed } : task
    ));
  };

  const completionRate = Math.round((tasks.filter(t => t.completed).length / tasks.length) * 100);
  const currentStreak = 14;

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50">
      {/* Header */}
      <header className="bg-white/40 backdrop-blur-2xl border-b border-white/20 sticky top-0 z-50 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 md:px-6 py-3 md:py-5">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2 md:gap-4">
              <div className="bg-gradient-to-br from-indigo-500 to-purple-500 p-2 rounded-xl md:rounded-2xl shadow-lg shadow-indigo-200">
                <Target className="w-5 h-5 md:w-6 md:h-6 text-white" />
              </div>
              <div>
                <h1 className="text-lg md:text-2xl font-bold text-slate-800 tracking-tight">Revenue Engine</h1>
                <p className="text-xs md:text-sm text-slate-500 font-medium hidden md:block">Outbound Sales Pod</p>
              </div>
            </div>
            
            <div className="flex items-center gap-3 md:gap-6">
              <div className="flex items-center gap-1.5 md:gap-2 bg-white/60 backdrop-blur-xl px-2 md:px-3 py-1.5 md:py-2 rounded-full border border-white/40 shadow-sm">
                <Flame className="w-3.5 h-3.5 md:w-4 md:h-4 text-orange-500" />
                <span className="text-slate-800 font-bold text-sm">{currentStreak}</span>
              </div>
              <button 
                onClick={() => setShowProfile(!showProfile)}
                className="w-9 h-9 md:w-10 md:h-10 rounded-full bg-gradient-to-br from-indigo-400 to-purple-500 flex items-center justify-center text-white font-semibold shadow-lg shadow-indigo-200 hover:scale-105 transition-all text-sm"
              >
                JD
              </button>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 md:px-6 py-4 md:py-8 pb-24 md:pb-28">
        {/* Today View */}
        {activeView === 'today' && (
          <div className="space-y-6 animate-fadeIn">
            {/* Stats Row */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              {[
                { label: 'Completion Rate', value: `${completionRate}%`, icon: Target, color: 'from-emerald-400 to-green-500', change: '+12%' },
                { label: 'Tasks Today', value: tasks.length, icon: CheckCircle2, color: 'from-blue-400 to-cyan-500', change: '5 done' },
                { label: 'Current Streak', value: currentStreak, icon: Flame, color: 'from-orange-400 to-rose-500', change: 'Best: 21' },
                { label: 'Team Rank', value: '#2', icon: Award, color: 'from-purple-400 to-pink-500', change: '↑ 1' },
              ].map((stat, i) => (
                <div key={i} className="bg-white/50 backdrop-blur-xl border border-white/60 rounded-2xl p-4 hover:bg-white/60 transition-all hover:shadow-lg shadow-sm">
                  <div className="flex items-center gap-2 mb-2">
                    <div className={`w-9 h-9 rounded-xl bg-gradient-to-br ${stat.color} flex items-center justify-center shadow-sm`}>
                      <stat.icon className="w-5 h-5 text-white" />
                    </div>
                    <div className="text-3xl font-bold text-slate-800">{stat.value}</div>
                  </div>
                  <div className="text-slate-600 text-xs font-medium mb-1">{stat.label}</div>
                  <div className="text-xs text-emerald-600 font-semibold">{stat.change}</div>
                </div>
              ))}
            </div>

            {/* Task List */}
            <div className="space-y-3">
              <div className="flex items-center justify-between mb-3 md:mb-4">
                <h2 className="text-xl md:text-2xl font-bold text-slate-800">Today's Mission</h2>
                <button 
                  onClick={() => setShowAddTask(true)}
                  className="bg-gradient-to-r from-indigo-500 to-purple-500 text-white px-4 md:px-6 py-2 md:py-3 rounded-xl md:rounded-2xl font-semibold hover:shadow-xl hover:shadow-indigo-300/50 transition-all flex items-center gap-2 shadow-lg shadow-indigo-200 text-sm md:text-base"
                >
                  <Plus className="w-4 h-4 md:w-5 md:h-5" />
                  <span className="hidden md:inline">Add Task</span>
                  <span className="md:hidden">Add</span>
                </button>
              </div>

              {tasks.map((task, i) => (
                <div
                  key={task.id}
                  className={`group bg-white/50 backdrop-blur-xl border border-white/60 rounded-2xl md:rounded-3xl p-4 md:p-6 hover:bg-white/70 transition-all hover:shadow-lg shadow-sm ${
                    task.completed ? 'opacity-60' : ''
                  }`}
                  style={{ animationDelay: `${i * 100}ms` }}
                >
                  <div className="flex items-start gap-3 md:gap-4">
                    <button
                      onClick={() => toggleTask(task.id)}
                      className="mt-0.5 md:mt-1 flex-shrink-0"
                    >
                      {task.completed ? (
                        <CheckCircle2 className="w-6 h-6 md:w-7 md:h-7 text-emerald-500" />
                      ) : (
                        <Circle className="w-6 h-6 md:w-7 md:h-7 text-slate-300 group-hover:text-slate-400 transition-colors" />
                      )}
                    </button>

                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-3 md:gap-4 mb-2 md:mb-3">
                        <div className="flex-1 min-w-0">
                          <h3 className={`text-base md:text-lg font-semibold mb-1 ${task.completed ? 'line-through text-slate-500' : 'text-slate-800'}`}>
                            {task.title}
                          </h3>
                          <div className="flex items-center gap-2 md:gap-3 flex-wrap">
                            <span className="text-xs md:text-sm text-slate-600 font-medium">{task.category}</span>
                            <span className="text-slate-300 hidden sm:inline">•</span>
                            <span className={`text-[10px] md:text-xs font-semibold px-2 md:px-2.5 py-0.5 md:py-1 rounded-full ${
                              task.type === 'Spear' ? 'bg-orange-100 text-orange-600' :
                              task.type === 'Seed' ? 'bg-green-100 text-green-600' :
                              'bg-blue-100 text-blue-600'
                            }`}>
                              {task.type}
                            </span>
                            <span className="text-slate-300 hidden sm:inline">•</span>
                            <div className="flex items-center gap-1 md:gap-1.5 bg-white/60 px-2 md:px-2.5 py-0.5 md:py-1 rounded-lg md:rounded-xl border border-white/40">
                              <Flame className="w-3 h-3 md:w-3.5 md:h-3.5 text-orange-500" />
                              <span className="text-slate-800 font-semibold text-[10px] md:text-xs">{task.streak}</span>
                            </div>
                          </div>
                        </div>

                        <div className="text-right flex-shrink-0">
                          <div className="text-slate-500 mb-1 md:mb-2 text-xs md:text-sm font-medium">
                            {task.time.replace(':00', '').replace(':30', ':30')}
                          </div>
                          {task.priority === 'high' && (
                            <span className="text-[10px] md:text-xs font-semibold px-2 md:px-3 py-0.5 md:py-1 rounded-full bg-rose-100 text-rose-600">
                              HIGH
                            </span>
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Team View */}
        {activeView === 'team' && (
          <div className="space-y-6 animate-fadeIn">
            <div className="flex items-center justify-between mb-4 md:mb-6">
              <h2 className="text-2xl md:text-3xl font-bold text-slate-800">Team Leaderboard</h2>
              <button 
                onClick={() => setShowInvite(true)}
                className="bg-white/60 backdrop-blur-xl border border-white/60 text-slate-700 px-4 md:px-6 py-2 md:py-3 rounded-xl md:rounded-2xl font-semibold hover:bg-white/80 transition-all flex items-center gap-2 shadow-sm text-sm md:text-base"
              >
                <Plus className="w-4 h-4 md:w-5 md:h-5" />
                <span className="hidden md:inline">Invite Member</span>
                <span className="md:hidden">Invite</span>
              </button>
            </div>

            <div className="space-y-3">
              {teamMembers.map((member, i) => (
                <div
                  key={i}
                  className="bg-white/50 backdrop-blur-xl border border-white/60 rounded-3xl p-6 hover:bg-white/70 transition-all hover:shadow-lg shadow-sm"
                  style={{ animationDelay: `${i * 100}ms` }}
                >
                  <div className="flex items-center gap-6">
                    <div className={`text-4xl font-bold ${
                      i === 0 ? 'text-yellow-500' :
                      i === 1 ? 'text-slate-400' :
                      i === 2 ? 'text-orange-400' :
                      'text-slate-300'
                    }`}>
                      #{i + 1}
                    </div>

                    <div className="w-14 h-14 rounded-full bg-gradient-to-br from-indigo-400 to-purple-500 flex items-center justify-center text-3xl shadow-lg shadow-indigo-200">
                      {member.avatar}
                    </div>

                    <div className="flex-1">
                      <h3 className="text-xl font-bold text-slate-800 mb-1">{member.name}</h3>
                      <div className="text-sm text-slate-600 font-medium">{member.role}</div>
                    </div>

                    <div className="text-center">
                      <div className="text-lg font-bold text-slate-800 mb-1">{member.completion}%</div>
                      <div className="text-xs text-slate-500 font-medium mb-3">Completion</div>
                      
                      <div className="bg-white/60 backdrop-blur-xl px-3 py-2 rounded-xl inline-flex items-center gap-2 border border-white/40">
                        <Flame className="w-4 h-4 text-orange-500" />
                        <span className="text-slate-800 font-semibold">{member.streak}</span>
                        <span className="text-slate-500 text-xs">days</span>
                      </div>
                    </div>

                    <div className={`w-16 h-16 rounded-full flex items-center justify-center ${
                      i === 0 ? 'bg-gradient-to-br from-yellow-400 to-orange-500 shadow-lg shadow-yellow-200' :
                      'bg-slate-200/50'
                    }`}>
                      {i === 0 && <Award className="w-8 h-8 text-white" />}
                    </div>
                  </div>

                  {/* Progress Bar */}
                  <div className="mt-4 bg-white/40 rounded-full h-2 overflow-hidden">
                    <div
                      className="h-full bg-gradient-to-r from-emerald-400 to-green-500 transition-all duration-1000"
                      style={{ width: `${member.completion}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Performance View */}
        {activeView === 'performance' && (
          <div className="space-y-6 animate-fadeIn">
            <h2 className="text-2xl md:text-3xl font-bold text-slate-800 mb-4 md:mb-6">Performance Analytics</h2>

            {/* Weekly Overview */}
            <div className="bg-white/50 backdrop-blur-xl border border-white/60 rounded-3xl p-8 shadow-sm">
              <h3 className="text-xl font-bold text-slate-800 mb-6">Weekly Activity</h3>
              <div className="grid grid-cols-7 gap-3">
                {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day, i) => {
                  const completion = [95, 87, 100, 92, 88, 45, 0][i];
                  return (
                    <div key={day} className="text-center">
                      <div className="text-slate-600 text-sm font-semibold mb-3">{day}</div>
                      <div className="bg-white/40 rounded-2xl p-4 h-32 flex flex-col justify-end border border-white/40">
                        <div
                          className={`rounded-t-lg transition-all ${
                            completion >= 90 ? 'bg-gradient-to-t from-emerald-400 to-green-500' :
                            completion >= 70 ? 'bg-gradient-to-t from-yellow-400 to-orange-500' :
                            completion > 0 ? 'bg-gradient-to-t from-rose-400 to-pink-500' :
                            'bg-slate-200/50'
                          }`}
                          style={{ height: `${completion}%` }}
                        />
                      </div>
                      <div className="text-slate-800 font-bold text-sm mt-2">{completion}%</div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Category Breakdown */}
            <div className="grid grid-cols-3 gap-4">
              {[
                { category: 'Cold Outreach', count: 42, target: 50, color: 'from-orange-400 to-rose-500' },
                { category: 'Follow-ups', count: 38, target: 40, color: 'from-blue-400 to-cyan-500' },
                { category: 'Reporting', count: 12, target: 15, color: 'from-purple-400 to-pink-500' },
              ].map((cat, i) => (
                <div key={i} className="bg-white/50 backdrop-blur-xl border border-white/60 rounded-3xl p-6 shadow-sm hover:bg-white/70 transition-all">
                  <h4 className="text-slate-800 font-bold mb-4">{cat.category}</h4>
                  <div className="mb-4">
                    <div className="flex items-baseline gap-2 mb-2">
                      <span className="text-4xl font-bold text-slate-800">{cat.count}</span>
                      <span className="text-slate-500 text-sm font-medium">/ {cat.target}</span>
                    </div>
                    <div className="bg-white/40 rounded-full h-2 overflow-hidden border border-white/40">
                      <div
                        className={`h-full bg-gradient-to-r ${cat.color} transition-all`}
                        style={{ width: `${(cat.count / cat.target) * 100}%` }}
                      />
                    </div>
                  </div>
                  <div className="text-emerald-600 text-sm font-semibold">
                    {Math.round((cat.count / cat.target) * 100)}% Complete
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Tasks Manager View */}
        {activeView === 'tasks' && (
          <div className="animate-fadeIn">
            <div className="flex items-center justify-between mb-4 md:mb-6">
              <h2 className="text-2xl md:text-3xl font-bold text-slate-800">Recurring Tasks</h2>
              <button 
                onClick={() => setShowAddTask(true)}
                className="bg-gradient-to-r from-indigo-500 to-purple-500 text-white px-4 md:px-8 py-2 md:py-4 rounded-xl md:rounded-2xl font-semibold hover:shadow-2xl hover:shadow-indigo-300/50 transition-all flex items-center gap-2 shadow-lg shadow-indigo-200 text-sm md:text-lg"
              >
                <Plus className="w-5 h-5 md:w-6 md:h-6" />
                <span className="hidden md:inline">Create Recurring Task</span>
                <span className="md:hidden">Create</span>
              </button>
            </div>

            <div className="bg-white/50 backdrop-blur-xl border border-white/60 rounded-3xl p-8 shadow-sm">
              <div className="grid grid-cols-3 gap-6 mb-8">
                {['Daily', 'Weekly', 'Monthly'].map(period => (
                  <button key={period} className="bg-white/60 hover:bg-white/80 border border-white/60 rounded-2xl p-4 text-slate-700 font-semibold transition-all shadow-sm">
                    {period} Tasks
                  </button>
                ))}
              </div>

              <div className="space-y-4">
                {tasks.map((task, i) => (
                  <div key={task.id} className="bg-white/40 border border-white/40 rounded-2xl p-6 hover:bg-white/60 transition-all">
                    <div className="flex items-center justify-between">
                      <div>
                        <h3 className="text-lg font-bold text-slate-800 mb-2">{task.title}</h3>
                        <div className="flex items-center gap-4 text-sm">
                          <span className="text-slate-600 font-medium">{task.category}</span>
                          <span className={`px-3 py-1 rounded-full font-semibold ${
                            task.priority === 'high' ? 'bg-rose-100 text-rose-600' : 'bg-blue-100 text-blue-600'
                          }`}>
                            {task.priority.toUpperCase()}
                          </span>
                        </div>
                      </div>
                      <div className="flex items-center gap-3">
                        <button className="px-6 py-2 bg-white/60 hover:bg-white/80 rounded-xl text-slate-700 font-semibold transition-all border border-white/40">
                          Edit
                        </button>
                        <button className="px-6 py-2 bg-rose-100 hover:bg-rose-200 text-rose-600 rounded-xl font-semibold transition-all">
                          Delete
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </main>

      {/* Add Task Modal */}
      {showAddTask && (
        <div className="fixed inset-0 bg-slate-900/20 backdrop-blur-sm z-50 flex items-center justify-center p-6">
          <div className="bg-white/80 backdrop-blur-2xl border border-white/60 rounded-3xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-8">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold text-slate-800">Create New Task</h2>
                <button 
                  onClick={() => setShowAddTask(false)}
                  className="w-10 h-10 rounded-full bg-slate-200/50 hover:bg-slate-300/50 flex items-center justify-center transition-all"
                >
                  <span className="text-slate-600 text-xl">×</span>
                </button>
              </div>

              <form className="space-y-5">
                {/* Task Title */}
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Task Title</label>
                  <input 
                    type="text"
                    placeholder="e.g., Send 50 Cold Emails"
                    className="w-full px-4 py-3 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500 text-slate-800 placeholder-slate-400"
                  />
                </div>

                {/* Description */}
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Description</label>
                  <textarea 
                    placeholder="Add details about this task..."
                    rows="3"
                    className="w-full px-4 py-3 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500 text-slate-800 placeholder-slate-400"
                  />
                </div>

                {/* Category & Type Row */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-semibold text-slate-700 mb-2">Category</label>
                    <select className="w-full px-4 py-3 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500 text-slate-800">
                      <option>Cold Outreach</option>
                      <option>Follow-ups</option>
                      <option>Reporting</option>
                      <option>Content</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-slate-700 mb-2">Type</label>
                    <select className="w-full px-4 py-3 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500 text-slate-800">
                      <option>Spear (Outbound)</option>
                      <option>Seed (Word-of-mouth)</option>
                      <option>Net (Marketing)</option>
                    </select>
                  </div>
                </div>

                {/* Recurrence & Priority Row */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-semibold text-slate-700 mb-2">Recurrence</label>
                    <select className="w-full px-4 py-3 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500 text-slate-800">
                      <option>Daily</option>
                      <option>Weekly</option>
                      <option>Monthly</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-slate-700 mb-2">Priority</label>
                    <select className="w-full px-4 py-3 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500 text-slate-800">
                      <option>High</option>
                      <option>Medium</option>
                      <option>Low</option>
                    </select>
                  </div>
                </div>

                {/* Assign To */}
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Assign To</label>
                  <div className="space-y-2">
                    {teamMembers.slice(0, 3).map((member, i) => (
                      <label key={i} className="flex items-center gap-3 p-3 bg-white/40 rounded-xl hover:bg-white/60 cursor-pointer transition-all">
                        <input type="checkbox" className="w-5 h-5 rounded border-slate-300 text-indigo-500 focus:ring-indigo-500" />
                        <span className="text-2xl">{member.avatar}</span>
                        <div>
                          <div className="font-semibold text-slate-800">{member.name}</div>
                          <div className="text-xs text-slate-500">{member.role}</div>
                        </div>
                      </label>
                    ))}
                  </div>
                </div>

                {/* Action Buttons */}
                <div className="flex gap-3 pt-4">
                  <button 
                    type="button"
                    onClick={() => setShowAddTask(false)}
                    className="flex-1 px-6 py-3 bg-white/60 border border-white/60 text-slate-700 rounded-xl font-semibold hover:bg-white/80 transition-all"
                  >
                    Cancel
                  </button>
                  <button 
                    type="submit"
                    className="flex-1 px-6 py-3 bg-gradient-to-r from-indigo-500 to-purple-500 text-white rounded-xl font-semibold hover:shadow-xl hover:shadow-indigo-300/50 transition-all"
                  >
                    Create Task
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Invite Member Modal */}
      {showInvite && (
        <div className="fixed inset-0 bg-slate-900/20 backdrop-blur-sm z-50 flex items-center justify-center p-6">
          <div className="bg-white/80 backdrop-blur-2xl border border-white/60 rounded-3xl shadow-2xl max-w-lg w-full">
            <div className="p-8">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold text-slate-800">Invite Team Member</h2>
                <button 
                  onClick={() => setShowInvite(false)}
                  className="w-10 h-10 rounded-full bg-slate-200/50 hover:bg-slate-300/50 flex items-center justify-center transition-all"
                >
                  <span className="text-slate-600 text-xl">×</span>
                </button>
              </div>

              <form className="space-y-5">
                {/* Email */}
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Email Address</label>
                  <input 
                    type="email"
                    placeholder="colleague@company.com"
                    className="w-full px-4 py-3 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500 text-slate-800 placeholder-slate-400"
                  />
                </div>

                {/* Name */}
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Full Name</label>
                  <input 
                    type="text"
                    placeholder="John Doe"
                    className="w-full px-4 py-3 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500 text-slate-800 placeholder-slate-400"
                  />
                </div>

                {/* Role */}
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Role</label>
                  <select className="w-full px-4 py-3 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500 text-slate-800">
                    <option>SDR (Sales Development Rep)</option>
                    <option>AE (Account Executive)</option>
                    <option>Marketing</option>
                    <option>Admin</option>
                  </select>
                </div>

                {/* Permission Level */}
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Permission Level</label>
                  <div className="space-y-2">
                    <label className="flex items-center gap-3 p-3 bg-white/40 rounded-xl hover:bg-white/60 cursor-pointer transition-all">
                      <input type="radio" name="permission" className="w-4 h-4 text-indigo-500 focus:ring-indigo-500" defaultChecked />
                      <div>
                        <div className="font-semibold text-slate-800">Member</div>
                        <div className="text-xs text-slate-500">Can view and complete assigned tasks</div>
                      </div>
                    </label>
                    <label className="flex items-center gap-3 p-3 bg-white/40 rounded-xl hover:bg-white/60 cursor-pointer transition-all">
                      <input type="radio" name="permission" className="w-4 h-4 text-indigo-500 focus:ring-indigo-500" />
                      <div>
                        <div className="font-semibold text-slate-800">Admin</div>
                        <div className="text-xs text-slate-500">Can create tasks and manage team</div>
                      </div>
                    </label>
                  </div>
                </div>

                {/* Action Buttons */}
                <div className="flex gap-3 pt-4">
                  <button 
                    type="button"
                    onClick={() => setShowInvite(false)}
                    className="flex-1 px-6 py-3 bg-white/60 border border-white/60 text-slate-700 rounded-xl font-semibold hover:bg-white/80 transition-all"
                  >
                    Cancel
                  </button>
                  <button 
                    type="submit"
                    className="flex-1 px-6 py-3 bg-gradient-to-r from-indigo-500 to-purple-500 text-white rounded-xl font-semibold hover:shadow-xl hover:shadow-indigo-300/50 transition-all"
                  >
                    Send Invite
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Profile Dropdown */}
      {showProfile && (
        <div className="fixed inset-0 z-40" onClick={() => setShowProfile(false)}>
          <div className="absolute top-20 right-6 bg-white/80 backdrop-blur-2xl border border-white/60 rounded-2xl shadow-2xl w-80 p-6" onClick={(e) => e.stopPropagation()}>
            {/* Profile Header */}
            <div className="flex items-center gap-4 mb-6 pb-6 border-b border-slate-200/50">
              <div className="w-16 h-16 rounded-full bg-gradient-to-br from-indigo-400 to-purple-500 flex items-center justify-center text-white font-bold text-xl shadow-lg shadow-indigo-200">
                JD
              </div>
              <div>
                <h3 className="font-bold text-slate-800 text-lg">John Doe</h3>
                <p className="text-sm text-slate-500">john.doe@company.com</p>
                <div className="mt-1 text-xs font-semibold px-2 py-1 bg-indigo-100 text-indigo-600 rounded-full inline-block">
                  Owner
                </div>
              </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-3 mb-6 pb-6 border-b border-slate-200/50">
              <div className="text-center">
                <div className="text-2xl font-bold text-slate-800">94%</div>
                <div className="text-xs text-slate-500">Completion</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-slate-800">14</div>
                <div className="text-xs text-slate-500">Day Streak</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-slate-800">#2</div>
                <div className="text-xs text-slate-500">Team Rank</div>
              </div>
            </div>

            {/* Menu Items */}
            <div className="space-y-2">
              <button className="w-full text-left px-4 py-3 rounded-xl hover:bg-white/60 transition-all text-slate-700 font-medium flex items-center gap-3">
                <Users className="w-5 h-5" />
                My Profile
              </button>
              <button className="w-full text-left px-4 py-3 rounded-xl hover:bg-white/60 transition-all text-slate-700 font-medium flex items-center gap-3">
                <Target className="w-5 h-5" />
                Goals & Targets
              </button>
              <button className="w-full text-left px-4 py-3 rounded-xl hover:bg-white/60 transition-all text-slate-700 font-medium flex items-center gap-3">
                <Zap className="w-5 h-5" />
                Notifications
              </button>
              <button className="w-full text-left px-4 py-3 rounded-xl hover:bg-white/60 transition-all text-slate-700 font-medium flex items-center gap-3">
                <BarChart3 className="w-5 h-5" />
                Settings
              </button>
            </div>

            {/* Logout */}
            <button className="w-full mt-4 px-4 py-3 bg-rose-100 hover:bg-rose-200 text-rose-600 rounded-xl font-semibold transition-all">
              Sign Out
            </button>
          </div>
        </div>
      )}

      {/* Bottom Navigation */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white/60 backdrop-blur-2xl border-t border-white/40 shadow-lg z-50">
        <div className="max-w-7xl mx-auto px-2 md:px-6">
          <div className="flex items-center justify-around py-2 md:py-3">
            {/* Today */}
            <button
              onClick={() => setActiveView('today')}
              className={`flex flex-col items-center gap-0.5 md:gap-1 px-2 md:px-4 py-1.5 md:py-2 transition-all ${
                activeView === 'today' ? 'text-indigo-600' : 'text-slate-500'
              }`}
            >
              <CheckCircle2 className="w-5 h-5 md:w-6 md:h-6" />
              <span className="text-[10px] md:text-xs font-semibold">Today</span>
            </button>

            {/* Team */}
            <button
              onClick={() => setActiveView('team')}
              className={`flex flex-col items-center gap-0.5 md:gap-1 px-2 md:px-4 py-1.5 md:py-2 transition-all ${
                activeView === 'team' ? 'text-indigo-600' : 'text-slate-500'
              }`}
            >
              <Users className="w-5 h-5 md:w-6 md:h-6" />
              <span className="text-[10px] md:text-xs font-semibold">Team</span>
            </button>

            {/* Add Button (Center) */}
            <button 
              onClick={() => setShowAddTask(true)}
              className="bg-gradient-to-r from-indigo-500 to-purple-500 text-white w-12 h-12 md:w-14 md:h-14 rounded-full flex items-center justify-center shadow-lg shadow-indigo-300/50 hover:shadow-xl hover:scale-105 transition-all -mt-4 md:-mt-6"
            >
              <Plus className="w-6 h-6 md:w-7 md:h-7" />
            </button>

            {/* Performance */}
            <button
              onClick={() => setActiveView('performance')}
              className={`flex flex-col items-center gap-0.5 md:gap-1 px-2 md:px-4 py-1.5 md:py-2 transition-all ${
                activeView === 'performance' ? 'text-indigo-600' : 'text-slate-500'
              }`}
            >
              <TrendingUp className="w-5 h-5 md:w-6 md:h-6" />
              <span className="text-[10px] md:text-xs font-semibold">Stats</span>
            </button>

            {/* Tasks */}
            <button
              onClick={() => setActiveView('tasks')}
              className={`flex flex-col items-center gap-0.5 md:gap-1 px-2 md:px-4 py-1.5 md:py-2 transition-all ${
                activeView === 'tasks' ? 'text-indigo-600' : 'text-slate-500'
              }`}
            >
              <Calendar className="w-5 h-5 md:w-6 md:h-6" />
              <span className="text-[10px] md:text-xs font-semibold">Tasks</span>
            </button>
          </div>
        </div>
      </nav>

      {/* Add Task Modal */}
      {showAddTask && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4 md:p-6">
          <div className="bg-white/90 backdrop-blur-2xl border border-white/60 rounded-2xl md:rounded-3xl p-6 md:p-8 max-w-2xl w-full shadow-2xl animate-fadeIn max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-4 md:mb-6">
              <h2 className="text-xl md:text-2xl font-bold text-slate-800">Create New Task</h2>
              <button 
                onClick={() => setShowAddTask(false)}
                className="w-10 h-10 rounded-full bg-slate-200 hover:bg-slate-300 flex items-center justify-center transition-all"
              >
                <span className="text-slate-600 text-xl">×</span>
              </button>
            </div>

            <div className="space-y-5">
              {/* Task Title */}
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-2">Task Title</label>
                <input 
                  type="text" 
                  placeholder="e.g., Send 50 Cold Emails"
                  className="w-full px-4 py-3 rounded-2xl bg-white/60 border border-white/60 focus:border-indigo-500 focus:outline-none text-slate-800 placeholder-slate-400"
                />
              </div>

              {/* Category */}
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-2">Category</label>
                <select 
                  className="w-full px-4 py-3 rounded-2xl bg-white/60 border border-white/60 focus:border-indigo-500 focus:outline-none text-slate-800"
                  onChange={(e) => {
                    if (e.target.value === 'add_new') {
                      setShowAddCategory(true);
                      e.target.value = 'Cold Outreach'; // Reset to first option
                    }
                  }}
                >
                  <option>Cold Outreach</option>
                  <option>Follow-ups</option>
                  <option>Reporting</option>
                  <option>Content</option>
                  {customCategories.map((cat, i) => (
                    <option key={i}>{cat}</option>
                  ))}
                  <option value="add_new" className="text-indigo-600 font-semibold">+ Add Category</option>
                </select>
              </div>

              {/* Type & Priority Row */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Type</label>
                  <select className="w-full px-4 py-3 rounded-2xl bg-white/60 border border-white/60 focus:border-indigo-500 focus:outline-none text-slate-800">
                    <option>Spear (Outbound)</option>
                    <option>Seed (Word-of-Mouth)</option>
                    <option>Net (Marketing)</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-2">Priority</label>
                  <select className="w-full px-4 py-3 rounded-2xl bg-white/60 border border-white/60 focus:border-indigo-500 focus:outline-none text-slate-800">
                    <option>High</option>
                    <option>Medium</option>
                    <option>Low</option>
                  </select>
                </div>
              </div>

              {/* Recurrence */}
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-2">Recurrence</label>
                <div className="grid grid-cols-3 gap-3">
                  <button className="px-4 py-3 rounded-2xl bg-indigo-500 text-white font-semibold shadow-sm">
                    Daily
                  </button>
                  <button className="px-4 py-3 rounded-2xl bg-white/60 border border-white/60 text-slate-700 font-semibold hover:bg-white/80 transition-all">
                    Weekly
                  </button>
                  <button className="px-4 py-3 rounded-2xl bg-white/60 border border-white/60 text-slate-700 font-semibold hover:bg-white/80 transition-all">
                    Monthly
                  </button>
                </div>
              </div>

              {/* Time */}
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-2">Scheduled Time</label>
                <input 
                  type="time" 
                  className="w-full px-4 py-3 rounded-2xl bg-white/60 border border-white/60 focus:border-indigo-500 focus:outline-none text-slate-800"
                />
              </div>

              {/* Assign To */}
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-2">Assign To</label>
                <div className="flex gap-2 flex-wrap">
                  {teamMembers.map((member, i) => (
                    <button key={i} className="px-4 py-2 rounded-full bg-white/60 border border-white/60 text-slate-700 font-medium hover:bg-indigo-500 hover:text-white transition-all text-sm">
                      {member.avatar} {member.name}
                    </button>
                  ))}
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex gap-3 pt-4">
                <button 
                  onClick={() => setShowAddTask(false)}
                  className="flex-1 px-6 py-3 rounded-2xl bg-white/60 border border-white/60 text-slate-700 font-semibold hover:bg-white/80 transition-all"
                >
                  Cancel
                </button>
                <button className="flex-1 px-6 py-3 rounded-2xl bg-gradient-to-r from-indigo-500 to-purple-500 text-white font-semibold shadow-lg shadow-indigo-200 hover:shadow-xl transition-all">
                  Create Task
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Invite Member Modal */}
      {showInvite && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4 md:p-6">
          <div className="bg-white/90 backdrop-blur-2xl border border-white/60 rounded-2xl md:rounded-3xl p-6 md:p-8 max-w-lg w-full shadow-2xl animate-fadeIn max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-4 md:mb-6">
              <h2 className="text-xl md:text-2xl font-bold text-slate-800">Invite Team Member</h2>
              <button 
                onClick={() => setShowInvite(false)}
                className="w-10 h-10 rounded-full bg-slate-200 hover:bg-slate-300 flex items-center justify-center transition-all"
              >
                <span className="text-slate-600 text-xl">×</span>
              </button>
            </div>

            <div className="space-y-5">
              {/* Email */}
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-2">Email Address</label>
                <input 
                  type="email" 
                  placeholder="colleague@company.com"
                  className="w-full px-4 py-3 rounded-2xl bg-white/60 border border-white/60 focus:border-indigo-500 focus:outline-none text-slate-800 placeholder-slate-400"
                />
              </div>

              {/* Role */}
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-2">Role</label>
                <select className="w-full px-4 py-3 rounded-2xl bg-white/60 border border-white/60 focus:border-indigo-500 focus:outline-none text-slate-800">
                  <option>SDR (Sales Development Rep)</option>
                  <option>AE (Account Executive)</option>
                  <option>Manager</option>
                  <option>Admin</option>
                </select>
              </div>

              {/* Permissions */}
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-3">Permissions</label>
                <div className="space-y-2">
                  <label className="flex items-center gap-3 p-3 rounded-xl bg-white/60 border border-white/60 cursor-pointer hover:bg-white/80 transition-all">
                    <input type="checkbox" defaultChecked className="w-5 h-5 rounded border-slate-300" />
                    <span className="text-sm text-slate-700 font-medium">View team performance</span>
                  </label>
                  <label className="flex items-center gap-3 p-3 rounded-xl bg-white/60 border border-white/60 cursor-pointer hover:bg-white/80 transition-all">
                    <input type="checkbox" defaultChecked className="w-5 h-5 rounded border-slate-300" />
                    <span className="text-sm text-slate-700 font-medium">Create & edit tasks</span>
                  </label>
                  <label className="flex items-center gap-3 p-3 rounded-xl bg-white/60 border border-white/60 cursor-pointer hover:bg-white/80 transition-all">
                    <input type="checkbox" className="w-5 h-5 rounded border-slate-300" />
                    <span className="text-sm text-slate-700 font-medium">Invite new members</span>
                  </label>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex gap-3 pt-4">
                <button 
                  onClick={() => setShowInvite(false)}
                  className="flex-1 px-6 py-3 rounded-2xl bg-white/60 border border-white/60 text-slate-700 font-semibold hover:bg-white/80 transition-all"
                >
                  Cancel
                </button>
                <button className="flex-1 px-6 py-3 rounded-2xl bg-gradient-to-r from-indigo-500 to-purple-500 text-white font-semibold shadow-lg shadow-indigo-200 hover:shadow-xl transition-all">
                  Send Invite
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Profile Modal */}
      {showProfile && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4 md:p-6">
          <div className="bg-white/90 backdrop-blur-2xl border border-white/60 rounded-2xl md:rounded-3xl p-6 md:p-8 max-w-lg w-full shadow-2xl animate-fadeIn max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-4 md:mb-6">
              <h2 className="text-xl md:text-2xl font-bold text-slate-800">Profile</h2>
              <button 
                onClick={() => setShowProfile(false)}
                className="w-10 h-10 rounded-full bg-slate-200 hover:bg-slate-300 flex items-center justify-center transition-all"
              >
                <span className="text-slate-600 text-xl">×</span>
              </button>
            </div>

            <div className="space-y-6">
              {/* Avatar Section */}
              <div className="flex flex-col items-center">
                <div className="w-24 h-24 rounded-full bg-gradient-to-br from-indigo-400 to-purple-500 flex items-center justify-center text-white font-bold text-3xl shadow-lg shadow-indigo-200 mb-4">
                  JD
                </div>
                <h3 className="text-xl font-bold text-slate-800">John Doe</h3>
                <p className="text-sm text-slate-500 font-medium">SDR • Outbound Sales Pod</p>
              </div>

              {/* Stats */}
              <div className="grid grid-cols-3 gap-3">
                <div className="bg-white/60 backdrop-blur-xl border border-white/60 rounded-2xl p-4 text-center">
                  <div className="text-2xl font-bold text-slate-800 mb-1">{currentStreak}</div>
                  <div className="text-xs text-slate-500 font-medium">Day Streak</div>
                </div>
                <div className="bg-white/60 backdrop-blur-xl border border-white/60 rounded-2xl p-4 text-center">
                  <div className="text-2xl font-bold text-slate-800 mb-1">94%</div>
                  <div className="text-xs text-slate-500 font-medium">Completion</div>
                </div>
                <div className="bg-white/60 backdrop-blur-xl border border-white/60 rounded-2xl p-4 text-center">
                  <div className="text-2xl font-bold text-slate-800 mb-1">#2</div>
                  <div className="text-xs text-slate-500 font-medium">Rank</div>
                </div>
              </div>

              {/* Settings Options */}
              <div className="space-y-2">
                <button className="w-full flex items-center justify-between p-4 rounded-2xl bg-white/60 border border-white/60 text-slate-700 font-medium hover:bg-white/80 transition-all">
                  <span>Edit Profile</span>
                  <span className="text-slate-400">→</span>
                </button>
                <button className="w-full flex items-center justify-between p-4 rounded-2xl bg-white/60 border border-white/60 text-slate-700 font-medium hover:bg-white/80 transition-all">
                  <span>Notifications</span>
                  <span className="text-slate-400">→</span>
                </button>
                <button className="w-full flex items-center justify-between p-4 rounded-2xl bg-white/60 border border-white/60 text-slate-700 font-medium hover:bg-white/80 transition-all">
                  <span>Settings</span>
                  <span className="text-slate-400">→</span>
                </button>
                <button className="w-full flex items-center justify-between p-4 rounded-2xl bg-rose-100 border border-rose-200 text-rose-600 font-medium hover:bg-rose-200 transition-all">
                  <span>Sign Out</span>
                  <span className="text-rose-400">→</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Add Category Dialog */}
      {showAddCategory && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-[60] flex items-center justify-center p-4 md:p-6">
          <div className="bg-white/90 backdrop-blur-2xl border border-white/60 rounded-2xl md:rounded-3xl p-6 md:p-8 max-w-md w-full shadow-2xl animate-fadeIn">
            <div className="flex items-center justify-between mb-4 md:mb-6">
              <h2 className="text-xl md:text-2xl font-bold text-slate-800">Add New Category</h2>
              <button 
                onClick={() => setShowAddCategory(false)}
                className="w-10 h-10 rounded-full bg-slate-200 hover:bg-slate-300 flex items-center justify-center transition-all"
              >
                <span className="text-slate-600 text-xl">×</span>
              </button>
            </div>

            <div className="space-y-5">
              {/* Category Name */}
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-2">Category Name</label>
                <input 
                  type="text" 
                  placeholder="e.g., Email Campaigns"
                  className="w-full px-4 py-3 rounded-2xl bg-white/60 border border-white/60 focus:border-indigo-500 focus:outline-none text-slate-800 placeholder-slate-400"
                  id="newCategoryInput"
                />
              </div>

              {/* Action Buttons */}
              <div className="flex gap-3 pt-2">
                <button 
                  onClick={() => setShowAddCategory(false)}
                  className="flex-1 px-6 py-3 rounded-2xl bg-white/60 border border-white/60 text-slate-700 font-semibold hover:bg-white/80 transition-all"
                >
                  Cancel
                </button>
                <button 
                  onClick={() => {
                    const input = document.getElementById('newCategoryInput');
                    if (input && input.value.trim()) {
                      setCustomCategories([...customCategories, input.value.trim()]);
                      setShowAddCategory(false);
                      input.value = '';
                    }
                  }}
                  className="flex-1 px-6 py-3 rounded-2xl bg-gradient-to-r from-indigo-500 to-purple-500 text-white font-semibold shadow-lg shadow-indigo-200 hover:shadow-xl transition-all"
                >
                  Add Category
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      <style jsx>{`
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');

        * {
          font-family: 'Inter', system-ui, -apple-system, sans-serif;
        }

        @keyframes fadeIn {
          from {
            opacity: 0;
            transform: translateY(20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        .animate-fadeIn {
          animation: fadeIn 0.5s ease-out forwards;
        }

        .animate-fadeIn > * {
          animation: fadeIn 0.6s ease-out forwards;
        }

        ::-webkit-scrollbar {
          width: 10px;
        }

        ::-webkit-scrollbar-track {
          background: rgba(255, 255, 255, 0.1);
        }

        ::-webkit-scrollbar-thumb {
          background: rgba(148, 163, 184, 0.5);
          border-radius: 5px;
        }

        ::-webkit-scrollbar-thumb:hover {
          background: rgba(148, 163, 184, 0.7);
        }
      `}</style>
    </div>
  );
}
