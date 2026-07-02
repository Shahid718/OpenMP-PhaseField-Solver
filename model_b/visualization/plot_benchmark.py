#!/usr/bin/env python3
"""
plot_benchmark.py
Beautiful performance visualization for Cahn-Hilliard benchmark results
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
import matplotlib.patches as mpatches

# ============================================================================
#  DATA
# ============================================================================

# Benchmark data - CONVERT TO NUMPY ARRAYS
grid_sizes = np.array([1000, 2000, 3000, 4000])
time_8threads = np.array([5.12, 21.32, 50.20, 87.38])
time_1thread = np.array([17.13, 70.01, 160.54, 285.38])

# Calculate speedup
speedup = time_1thread / time_8threads

# Calculate efficiency (speedup / 8 * 100)
efficiency = (speedup / 8.0) * 100.0

# Calculate MLUPs/s for each case
updates = np.array([g**2 * 2000 for g in grid_sizes])  # 2000 time steps
mlups_8threads = updates / (time_8threads * 1e6)
mlups_1thread = updates / (time_1thread * 1e6)

# Calculate GFLOPS/s (assuming ~50 FLOPs per update)
gflops_8threads = mlups_8threads * 50 / 1000
gflops_1thread = mlups_1thread * 50 / 1000

# ============================================================================
#  FIGURE 1: Strong Scaling - Time vs Grid Size
# ============================================================================

fig1, ax1 = plt.subplots(figsize=(10, 7))

# Colors
color_8 = '#1f77b4'  # Blue
color_1 = '#ff7f0e'  # Orange
color_ideal = '#2ca02c'  # Green

# Plot data
ax1.plot(grid_sizes, time_8threads, 'o-', color=color_8, 
         linewidth=2.5, markersize=10, label='8 Threads (OpenMP)')
ax1.plot(grid_sizes, time_1thread, 's-', color=color_1, 
         linewidth=2.5, markersize=10, label='1 Thread (Serial)')

# Add value labels on points
for x, y, label in zip(grid_sizes, time_8threads, time_8threads):
    ax1.annotate(f'{y:.2f}s', (x, y), textcoords="offset points", 
                 xytext=(0, 12), ha='center', fontsize=9, fontweight='bold')
for x, y, label in zip(grid_sizes, time_1thread, time_1thread):
    ax1.annotate(f'{y:.2f}s', (x, y), textcoords="offset points", 
                 xytext=(0, 12), ha='center', fontsize=9, fontweight='bold')

# Formatting
ax1.set_xlabel('Grid Size (N × N)', fontsize=14, fontweight='bold')
ax1.set_ylabel('Execution Time (seconds)', fontsize=14, fontweight='bold')
ax1.set_title('Strong Scaling: Cahn-Hilliard Simulation\n(2000 Time Steps)', 
              fontsize=16, fontweight='bold', pad=20)
ax1.grid(True, alpha=0.3, linestyle='--')
ax1.legend(loc='upper left', fontsize=12, framealpha=0.95)
ax1.set_xscale('log', base=2)
ax1.set_yscale('log')
ax1.set_xticks(grid_sizes)
ax1.set_xticklabels([f'{g}×{g}' for g in grid_sizes])
ax1.tick_params(axis='both', labelsize=11)

# Add shading for scaling region
ax1.fill_between(grid_sizes, time_8threads, time_1thread, 
                  alpha=0.15, color='gray', label='Parallel Speedup Region')
ax1.text(1500, 180, 'Speedup\nRegion', ha='center', va='center', 
         fontsize=10, color='gray', fontweight='bold')

plt.tight_layout()
plt.savefig('benchmark_scaling.svg', dpi=300, bbox_inches='tight')
plt.savefig('benchmark_scaling.pdf', bbox_inches='tight')

# ============================================================================
#  FIGURE 2: Speedup and Efficiency
# ============================================================================

fig2, ax2 = plt.subplots(figsize=(10, 7))

# Create secondary axis for efficiency
ax2_e = ax2.twinx()

# Plot speedup
bars1 = ax2.bar(np.array(grid_sizes) - 100, speedup, width=150, 
                 color='steelblue', alpha=0.8, label='Speedup', 
                 edgecolor='navy', linewidth=1.5)

# Plot efficiency on secondary axis
bars2 = ax2_e.bar(np.array(grid_sizes) + 100, efficiency, width=150,
                   color='coral', alpha=0.8, label='Efficiency (%)',
                   edgecolor='darkred', linewidth=1.5)

# Add value labels on bars
for bar, val, eff in zip(bars1, speedup, efficiency):
    height = bar.get_height()
    ax2.annotate(f'{val:.2f}x', 
                xy=(bar.get_x() + bar.get_width()/2, height),
                xytext=(0, 5), textcoords="offset points",
                ha='center', va='bottom', fontsize=10, fontweight='bold')
for bar, val, eff in zip(bars2, speedup, efficiency):
    height = bar.get_height()
    ax2_e.annotate(f'{eff:.1f}%', 
                  xy=(bar.get_x() + bar.get_width()/2, height),
                  xytext=(0, 5), textcoords="offset points",
                  ha='center', va='bottom', fontsize=10, fontweight='bold')

# Ideal speedup line (8x)
ax2.axhline(y=8, color='red', linestyle='--', linewidth=2, alpha=0.7, 
           label='Ideal Speedup (8×)')

# Formatting
ax2.set_xlabel('Grid Size (N × N)', fontsize=14, fontweight='bold')
ax2.set_ylabel('Speedup', fontsize=14, fontweight='bold', color='steelblue')
ax2_e.set_ylabel('Efficiency (%)', fontsize=14, fontweight='bold', color='coral')
ax2.set_title('Parallel Performance: Speedup & Efficiency\n(8 Threads vs 1 Thread)', 
              fontsize=16, fontweight='bold', pad=20)
ax2.grid(True, alpha=0.3, linestyle='--')
ax2.set_xticks(grid_sizes)
ax2.set_xticklabels([f'{g}×{g}' for g in grid_sizes])
ax2.tick_params(axis='y', labelcolor='steelblue')
ax2_e.tick_params(axis='y', labelcolor='coral')
ax2.legend(loc='upper left', fontsize=11, framealpha=0.95)
ax2_e.legend(loc='upper right', fontsize=11, framealpha=0.95)

# Add ideal efficiency line (100%)
ax2_e.axhline(y=100, color='green', linestyle=':', linewidth=2, alpha=0.5,
              label='Ideal Efficiency (100%)')

plt.tight_layout()
plt.savefig('benchmark_speedup.svg', dpi=300, bbox_inches='tight')
plt.savefig('benchmark_speedup.pdf', bbox_inches='tight')

# ============================================================================
#  FIGURE 3: Performance (MLUPs/s) and GFLOPS/s
# ============================================================================

fig3, ax3 = plt.subplots(figsize=(10, 7))

# Plot MLUPs
ax3.plot(grid_sizes, mlups_8threads, 'o-', color='darkblue', 
         linewidth=2.5, markersize=10, label='8 Threads (MLUPs/s)')
ax3.plot(grid_sizes, mlups_1thread, 's-', color='darkorange', 
         linewidth=2.5, markersize=10, label='1 Thread (MLUPs/s)')

# Add value labels
for x, y in zip(grid_sizes, mlups_8threads):
    ax3.annotate(f'{y:.1f}', (x, y), textcoords="offset points", 
                 xytext=(0, 12), ha='center', fontsize=9, fontweight='bold')
for x, y in zip(grid_sizes, mlups_1thread):
    ax3.annotate(f'{y:.1f}', (x, y), textcoords="offset points", 
                 xytext=(0, 12), ha='center', fontsize=9, fontweight='bold')

# Formatting
ax3.set_xlabel('Grid Size (N × N)', fontsize=14, fontweight='bold')
ax3.set_ylabel('Performance (MLUPs/s)', fontsize=14, fontweight='bold')
ax3.set_title('Computational Performance\n(2000 Time Steps)', 
              fontsize=16, fontweight='bold', pad=20)
ax3.grid(True, alpha=0.3, linestyle='--')
ax3.legend(loc='best', fontsize=12, framealpha=0.95)
ax3.set_xticks(grid_sizes)
ax3.set_xticklabels([f'{g}×{g}' for g in grid_sizes])
ax3.tick_params(axis='both', labelsize=11)

plt.tight_layout()
plt.savefig('benchmark_performance.svg', dpi=300, bbox_inches='tight')
plt.savefig('benchmark_performance.pdf', bbox_inches='tight')

# ============================================================================
#  FIGURE 4: Summary Table (Visual Table)
# ============================================================================

fig4, ax4 = plt.subplots(figsize=(12, 6))
ax4.axis('tight')
ax4.axis('off')

# Create table data
table_data = [
    ['Grid Size', '1 Thread (s)', '8 Threads (s)', 'Speedup', 'Efficiency'],
    ['1000×1000', f'{time_1thread[0]:.2f}', f'{time_8threads[0]:.2f}', 
     f'{speedup[0]:.2f}x', f'{efficiency[0]:.1f}%'],
    ['2000×2000', f'{time_1thread[1]:.2f}', f'{time_8threads[1]:.2f}', 
     f'{speedup[1]:.2f}x', f'{efficiency[1]:.1f}%'],
    ['3000×3000', f'{time_1thread[2]:.2f}', f'{time_8threads[2]:.2f}', 
     f'{speedup[2]:.2f}x', f'{efficiency[2]:.1f}%'],
    ['4000×4000', f'{time_1thread[3]:.2f}', f'{time_8threads[3]:.2f}', 
     f'{speedup[3]:.2f}x', f'{efficiency[3]:.1f}%'],
    ['Average', '-', '-', f'{np.mean(speedup):.2f}x', f'{np.mean(efficiency):.1f}%']
]

# Create table
table = ax4.table(cellText=table_data, loc='center', cellLoc='center',
                  colWidths=[0.15, 0.15, 0.15, 0.15, 0.15])

# Style the table
table.auto_set_font_size(False)
table.set_fontsize(12)
table.scale(1, 2)

# Color header row
for j in range(5):
    table[(0, j)].set_facecolor('#2c3e50')
    table[(0, j)].set_text_props(weight='bold', color='white')

# Color alternating rows
colors = ['#ecf0f1', '#ffffff']
for i in range(1, 6):
    for j in range(5):
        table[(i, j)].set_facecolor(colors[i % 2])

# Highlight best values
table[(1, 3)].set_text_props(weight='bold', color='green')  # Best speedup
table[(4, 3)].set_text_props(weight='bold', color='green')
table[(1, 4)].set_text_props(weight='bold', color='blue')   # Best efficiency
table[(4, 4)].set_text_props(weight='bold', color='blue')

# Add title
ax4.set_title('Cahn-Hilliard Performance Summary\n(2000 Time Steps, Intel ifx on Windows 11)', 
              fontsize=16, fontweight='bold', pad=30)

plt.tight_layout()
plt.savefig('benchmark_summary.svg', dpi=300, bbox_inches='tight')
plt.savefig('benchmark_summary.pdf', bbox_inches='tight')

# ============================================================================
#  FIGURE 5: Combined Dashboard
# ============================================================================

fig5 = plt.figure(figsize=(16, 10))

# Subplot 1: Time vs Grid Size
ax1 = plt.subplot(2, 2, 1)
ax1.plot(grid_sizes, time_8threads, 'o-', color='#1f77b4', linewidth=3, markersize=10)
ax1.plot(grid_sizes, time_1thread, 's-', color='#ff7f0e', linewidth=3, markersize=10)
ax1.set_xlabel('Grid Size (N×N)', fontsize=12, fontweight='bold')
ax1.set_ylabel('Time (s)', fontsize=12, fontweight='bold')
ax1.set_title('Execution Time', fontsize=14, fontweight='bold')
ax1.grid(True, alpha=0.3)
ax1.legend(['8 Threads', '1 Thread'], loc='upper left')
ax1.set_xticks(grid_sizes)
ax1.set_xticklabels([f'{g}' for g in grid_sizes])

# Subplot 2: Speedup
ax2 = plt.subplot(2, 2, 2)
ax2.bar(grid_sizes, speedup, width=200, color='steelblue', alpha=0.8, 
        edgecolor='navy', linewidth=1.5)
ax2.axhline(y=8, color='red', linestyle='--', linewidth=2, alpha=0.7, label='Ideal (8×)')
for x, y in zip(grid_sizes, speedup):
    ax2.annotate(f'{y:.2f}x', (x, y), textcoords="offset points", 
                 xytext=(0, 8), ha='center', fontsize=10, fontweight='bold')
ax2.set_xlabel('Grid Size (N×N)', fontsize=12, fontweight='bold')
ax2.set_ylabel('Speedup', fontsize=12, fontweight='bold')
ax2.set_title('Parallel Speedup', fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.3, axis='y')
ax2.legend(loc='upper left')
ax2.set_xticks(grid_sizes)
ax2.set_xticklabels([f'{g}' for g in grid_sizes])

# Subplot 3: MLUPs/s
ax3 = plt.subplot(2, 2, 3)
width = 150
x_pos = np.array(grid_sizes)
ax3.bar(x_pos - width/2, mlups_1thread, width, label='1 Thread', color='#ff7f0e', alpha=0.8)
ax3.bar(x_pos + width/2, mlups_8threads, width, label='8 Threads', color='#1f77b4', alpha=0.8)
for x, y1, y2 in zip(grid_sizes, mlups_1thread, mlups_8threads):
    ax3.annotate(f'{y1:.1f}', (x - width/2, y1), textcoords="offset points", 
                 xytext=(0, 4), ha='center', fontsize=8)
    ax3.annotate(f'{y2:.1f}', (x + width/2, y2), textcoords="offset points", 
                 xytext=(0, 4), ha='center', fontsize=8)
ax3.set_xlabel('Grid Size (N×N)', fontsize=12, fontweight='bold')
ax3.set_ylabel('MLUPs/s', fontsize=12, fontweight='bold')
ax3.set_title('Computational Performance', fontsize=14, fontweight='bold')
ax3.grid(True, alpha=0.3, axis='y')
ax3.legend(loc='upper left')
ax3.set_xticks(grid_sizes)
ax3.set_xticklabels([f'{g}' for g in grid_sizes])

# Subplot 4: Efficiency
ax4 = plt.subplot(2, 2, 4)
ax4.bar(grid_sizes, efficiency, width=200, color='coral', alpha=0.8, 
        edgecolor='darkred', linewidth=1.5)
ax4.axhline(y=100, color='green', linestyle='--', linewidth=2, alpha=0.5, label='Ideal (100%)')
ax4.axhline(y=80, color='orange', linestyle=':', linewidth=2, alpha=0.5, label='Good (80%)')
for x, y in zip(grid_sizes, efficiency):
    ax4.annotate(f'{y:.1f}%', (x, y), textcoords="offset points", 
                 xytext=(0, 8), ha='center', fontsize=10, fontweight='bold')
ax4.set_xlabel('Grid Size (N×N)', fontsize=12, fontweight='bold')
ax4.set_ylabel('Efficiency (%)', fontsize=12, fontweight='bold')
ax4.set_title('Parallel Efficiency', fontsize=14, fontweight='bold')
ax4.grid(True, alpha=0.3, axis='y')
ax4.legend(loc='upper left')
ax4.set_ylim(0, 120)
ax4.set_xticks(grid_sizes)
ax4.set_xticklabels([f'{g}' for g in grid_sizes])

plt.suptitle('Cahn-Hilliard Benchmark Results\nIntel ifx Compiler, Windows 11, 2000 Time Steps', 
             fontsize=18, fontweight='bold', y=0.98)

plt.tight_layout()
plt.savefig('benchmark_dashboard.svg', dpi=300, bbox_inches='tight')
plt.savefig('benchmark_dashboard.pdf', bbox_inches='tight')

# ============================================================================
#  PRINT SUMMARY
# ============================================================================

print("\n" + "="*60)
print("  BENCHMARK SUMMARY")
print("="*60)
print(f"\n  {'Grid Size':<12} {'1 Thread':<12} {'8 Threads':<12} {'Speedup':<10} {'Efficiency':<12}")
print("  " + "-"*60)
for g, t1, t8, sp, eff in zip(grid_sizes, time_1thread, time_8threads, speedup, efficiency):
    print(f"  {g}×{g:<6} {t1:<12.2f} {t8:<12.2f} {sp:<10.2f}x {eff:<12.1f}%")
print("  " + "-"*60)
print(f"  {'Average':<12} {'-':<12} {'-':<12} {np.mean(speedup):<10.2f}x {np.mean(efficiency):<12.1f}%")
print("="*60)

print("\n✅ Plots generated:")
print("  1. benchmark_scaling.svg      - Strong scaling plot")
print("  2. benchmark_speedup.svg      - Speedup & Efficiency bars")
print("  3. benchmark_performance.svg  - MLUPs/s performance")
print("  4. benchmark_summary.svg      - Summary table")
print("  5. benchmark_dashboard.svg    - Combined dashboard")
print("\n📁 Also saved as PDF versions for publication quality!")

plt.show()