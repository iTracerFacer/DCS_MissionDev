# TADC Smart Threat Prioritization System

## Overview
The enhanced Tactical Air Defense Controller (TADC) now includes a comprehensive smart threat prioritization system that uses multi-factor analysis to assess threats and assign the most appropriate squadrons for intercepts.

## Key Features

### 1. Multi-Factor Threat Priority Calculation
The system evaluates threats based on multiple weighted factors:

- **Base Threat Type (40% weight)**
  - Bombers: 100 points (highest threat - can destroy strategic targets)
  - Attack Aircraft: 85 points (high threat - ground attack capability)
  - Fighters: 70 points (medium threat - air superiority)
  - Helicopters: 50 points (lower threat but still dangerous)

- **Formation Size Factor (15% weight)**
  - Each additional aircraft adds 30% threat multiplier
  - Capped at 250% maximum multiplier

- **Strategic Proximity Analysis (25% weight)**
  - Exponential threat increase closer to strategic targets
  - Considers airbase importance weighting
  - 75km threat radius around strategic targets

- **Speed and Heading Analysis (10% weight)**
  - Fast-moving aircraft are more threatening (less intercept time)
  - Heading toward strategic targets increases threat
  - Supersonic aircraft get highest speed bonus

- **Temporal Factors (10% weight)**
  - Night operations bonus (reduced defender visibility)
  - Weather considerations (framework ready)

- **Electronic Warfare Considerations**
  - EW aircraft (EA-, EF-) get high priority
  - Stealth aircraft (F-22, F-35) get threat bonus

### 2. Predictive Threat Assessment
- **Future Position Prediction**: Calculates where threats will be in 5 minutes
- **Time-to-Target Analysis**: Determines how long until threat reaches strategic targets
- **Intercept Window Calculation**: Optimizes response timing
- **Response Urgency Classification**:
  - EMERGENCY: < 5 minutes to target (150% priority boost)
  - URGENT: < 10 minutes to target (130% priority boost)
  - HIGH: < 20 minutes to target (110% priority boost)
  - STANDARD: > 20 minutes to target

### 3. Enhanced Squadron-Threat Matching
The system now intelligently matches squadrons to threats based on:

- **Distance Factor (40% of match score)**
  - Exponential scoring favoring closer squadrons
  - 75km ideal response range

- **Threat Type Specialization (30% of match score)**
  - Helicopter squadrons perfect for anti-helicopter missions
  - Fighter squadrons excel against bombers and attack aircraft
  - Type-specific bonuses for optimal pairing

- **Squadron Readiness (20% of match score)**
  - More available aircraft = higher score
  - Alert level considerations (GREEN/YELLOW/RED)
  - Fatigue factor penalties

- **Response Urgency Matching (10% of match score)**
  - Emergency responses get priority multipliers
  - All squadrons receive urgency bonuses for critical threats

### 4. Strategic Target Protection
The system maintains a database of strategic targets with importance weights:

- **Airbases** (Importance: 85-100)
  - Severomorsk-1: 100 (Primary intercept base)
  - Olenya: 95 (Northern coverage)
  - Murmansk: 90 (Western coverage)
  - Afrikanda: 85 (Helicopter base)

- **SAM Sites** (Importance: 60-70)
  - SA-10 Sites: 70
  - SA-11 Sites: 60

- **Command Centers** (Importance: 80)

### 5. Advanced Logging and Debugging
Enhanced debug output provides detailed information:
```
=== SMART THREAT ASSESSMENT: RED_BORDER ===
1. F/A-18C Hornet (ATTACK x2) Priority:145 TTT:3.2m Response:URGENT
2. F-16C Viper (FIGHTER x1) Priority:89 TTT:8.7m Response:HIGH
3. AH-64D Apache (HELICOPTER x1) Priority:67 TTT:15.1m Response:STANDARD

✓ SMART ASSIGNMENT: FIGHTER_SWEEP_RED_Severomorsk-1 → F/A-18C Hornet (ATTACK x2) Score:87.3 Priority:145 TTT:3.2m URGENT
```

## Configuration Options

### Smart Prioritization Settings
```lua
-- Enhanced threat assessment
enableSmartPrioritization = true,    -- Enable smart threat analysis
strategicTargetRadius = 75000,       -- Threat radius around strategic targets (75km)
emergencyResponseTime = 300,         -- Emergency threshold (5 minutes)
urgentResponseTime = 600,           -- Urgent threshold (10 minutes)

-- Squadron matching
enableEnhancedMatching = true,       -- Enable smart squadron-threat matching
typeSpecializationWeight = 0.3,      -- Weight for type matching (30%)
distanceWeight = 0.4,               -- Weight for distance factor (40%)
readinessWeight = 0.2,              -- Weight for squadron readiness (20%)
```

### Debug Levels
- **Level 0**: Silent operation
- **Level 1**: Basic threat assessment and assignment logging
- **Level 2**: Detailed scoring breakdown and squadron matching analysis

## Performance Impact
The smart prioritization system adds minimal performance overhead:
- Threat calculations are only performed when threats are detected
- Strategic target coordinates are cached on initialization
- Efficient sorting algorithms used for priority ranking

## Benefits
1. **More Effective Defense**: Highest priority threats are engaged first
2. **Optimal Resource Allocation**: Best-suited squadrons assigned to appropriate threats
3. **Predictive Response**: System anticipates threat movements and timing
4. **Strategic Protection**: Critical assets receive priority defense
5. **Realistic Threat Assessment**: Multi-factor analysis mirrors real-world threat evaluation

## Future Enhancements
- Weather-based threat modifications
- Terrain masking considerations
- Electronic warfare environment effects
- Machine learning threat pattern recognition
- Dynamic strategic target importance based on mission phase

The smart prioritization system transforms the TADC from a reactive system into a truly intelligent air defense controller that can anticipate, prioritize, and respond to threats with military-grade effectiveness.