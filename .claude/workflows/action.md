# Meteorite Development Workflows

This file defines custom workflows for the Meteorite iPhone app development using Claude Code and GitHub integration.

## Development Workflow Commands

### GitHub Issue Management

Create and manage GitHub issues for task tracking:

```bash
# Create new feature issue
gh issue create --title "Feature: [Feature Name]" --body "## Description\n[Feature description]\n\n## Acceptance Criteria\n- [ ] Criterion 1\n- [ ] Criterion 2\n\n## Technical Notes\n[Any technical considerations]" --label "enhancement"

# Create bug report
gh issue create --title "Bug: [Bug Description]" --body "## Description\n[Bug description]\n\n## Steps to Reproduce\n1. Step 1\n2. Step 2\n\n## Expected vs Actual Behavior\n**Expected:** [Expected behavior]\n**Actual:** [Actual behavior]\n\n## Environment\n- iOS Version: [version]\n- Device: [device]" --label "bug"

# List current issues
gh issue list --state open

# Close issue when completed
gh issue close [issue-number]
```

### Branch Management

Standard Git workflow for feature development:

```bash
# Create feature branch from main
git checkout main && git pull origin main
git checkout -b feature/[feature-name]

# Work on feature and commit changes
git add .
git commit -m "Add [feature description]

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push feature branch
git push -u origin feature/[feature-name]

# Create pull request
gh pr create --title "Feature: [Feature Name]" --body "## Summary\n- Implements [feature]\n- Adds [functionality]\n\n## Test Plan\n- [ ] Test camera functionality\n- [ ] Verify ML analysis\n- [ ] Check UI responsiveness\n\n🤖 Generated with [Claude Code](https://claude.ai/code)"
```

### Xcode Project Management

Commands for working with the Xcode project:

```bash
# Open project in Xcode
open Meteorite.xcodeproj

# Build project from command line
xcodebuild -project Meteorite.xcodeproj -scheme Meteorite -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run tests
xcodebuild test -project Meteorite.xcodeproj -scheme Meteorite -destination 'platform=iOS Simulator,name=iPhone 15'

# Clean build folder
xcodebuild clean -project Meteorite.xcodeproj -scheme Meteorite
```

## Custom Workflow Shortcuts

### Quick Feature Implementation

For rapid feature development:

1. Create GitHub issue for the feature
2. Create feature branch
3. Implement feature with proper MVVM architecture
4. Add unit tests if applicable
5. Test on device/simulator
6. Create pull request with detailed description
7. Merge after review

### ML Model Integration Workflow

For adding new ML capabilities:

1. Research and validate ML approach
2. Create model service in `Services/`
3. Implement Core ML integration
4. Add Vision framework processing
5. Test with various input scenarios
6. Optimize for real-time performance
7. Document model capabilities

### Camera Feature Development

For camera-related features:

1. Implement camera service using AVFoundation
2. Handle permissions and privacy
3. Add real-time preview
4. Implement capture functionality
5. Test on physical device (camera features require real device)
6. Verify performance and memory usage

## Issue Templates

### Feature Request Template
```markdown
## Feature Description
[Describe the feature]

## User Story
As a photographer, I want [functionality] so that [benefit].

## Acceptance Criteria
- [ ] Functional requirement 1
- [ ] Functional requirement 2
- [ ] Performance requirement
- [ ] UI/UX requirement

## Technical Considerations
- Core ML integration needed: [Yes/No]
- Camera functionality changes: [Yes/No]
- New dependencies: [List any]

## Design Notes
[Any UI/UX considerations]
```

### Bug Report Template
```markdown
## Bug Description
[Clear description of the bug]

## Steps to Reproduce
1. [First step]
2. [Second step]
3. [Continue...]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- iOS Version: [version]
- Device Model: [model]
- App Version: [version]

## Screenshots/Videos
[If applicable]

## Additional Context
[Any other relevant information]
```

## Development Standards

### Commit Message Format
```
[Type]: [Brief description]

[Optional detailed description]

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Types: feat, fix, refactor, test, docs, style, perf

### Code Review Checklist
- [ ] Follows MVVM architecture
- [ ] Includes appropriate error handling
- [ ] Camera permissions handled properly
- [ ] ML processing doesn't block UI
- [ ] Memory management considered
- [ ] SwiftUI best practices followed
- [ ] No hardcoded values
- [ ] Proper documentation/comments

### Testing Requirements
- [ ] Unit tests for business logic
- [ ] Camera functionality tested on device
- [ ] ML models tested with various inputs
- [ ] UI tested in different orientations
- [ ] Performance verified (60fps camera)
- [ ] Memory leaks checked

## GitHub Integration

All development should leverage GitHub features:
- Issues for task management
- Pull requests for code review
- Projects for milestone tracking
- Actions for CI/CD (when needed)
- Wiki for additional documentation

This workflow ensures efficient development while maintaining code quality and proper documentation throughout the Meteorite app development process.