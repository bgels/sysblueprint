# Contributing to Systems Labs Blueprints

Thank you for your interest in contributing to the Systems Labs Blueprints project! This document provides guidelines for contributing new blueprints, improving existing ones, and maintaining the repository.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Blueprint Guidelines](#blueprint-guidelines)
- [Submission Process](#submission-process)
- [Review Process](#review-process)
- [Style Guide](#style-guide)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors. We expect all participants to:

- Be respectful and considerate
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment or discriminatory language
- Personal attacks or trolling
- Publishing others' private information
- Other conduct that could reasonably be considered inappropriate

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

1. **New Blueprints**: Create comprehensive lab environment documentation
2. **Blueprint Improvements**: Enhance existing blueprints with better instructions, troubleshooting, or optimizations
3. **Bug Fixes**: Correct errors in commands, configurations, or documentation
4. **Automation Scripts**: Add scripts to automate blueprint setup
5. **Documentation**: Improve guides, add examples, or clarify instructions
6. **Testing**: Validate blueprints and report issues

### Getting Started

1. **Fork the Repository**
   ```bash
   # Click "Fork" on GitHub
   git clone https://github.com/YOUR-USERNAME/sysblueprint.git
   cd sysblueprint
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/my-new-blueprint
   # or
   git checkout -b fix/networking-blueprint-issue
   ```

3. **Make Your Changes**
   - Follow the blueprint template for new blueprints
   - Test all commands and procedures
   - Update documentation as needed

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: Add high-availability web cluster blueprint"
   ```

5. **Push to Your Fork**
   ```bash
   git push origin feature/my-new-blueprint
   ```

6. **Create a Pull Request**
   - Go to the original repository on GitHub
   - Click "New Pull Request"
   - Provide a clear description of your changes

## Blueprint Guidelines

### Quality Standards

All blueprints must meet these standards:

#### Completeness

- [ ] Includes all required sections from the template
- [ ] Provides clear overview and use cases
- [ ] Documents all hardware and software requirements
- [ ] Contains step-by-step setup instructions
- [ ] Includes validation procedures
- [ ] Has troubleshooting guidance
- [ ] Lists maintenance procedures
- [ ] Provides relevant references

#### Technical Accuracy

- [ ] All commands have been tested
- [ ] Version numbers are specified
- [ ] Expected outputs are documented
- [ ] Error conditions are addressed
- [ ] Network diagrams are accurate
- [ ] Resource requirements are realistic

#### Clarity

- [ ] Written in clear, concise language
- [ ] Commands include explanatory comments
- [ ] Technical terms are explained
- [ ] Assumptions are stated
- [ ] Prerequisites are clear

### Blueprint Structure

Use the template in `templates/blueprint-template.md`:

```
# Blueprint Title

## Overview
- Purpose
- Use cases

## Architecture
- System topology
- Components table

## Requirements
- Hardware requirements
- Software requirements

## Setup Instructions
- Step-by-step procedures
- Configuration commands

## Validation
- Test procedures
- Expected outputs

## Usage
- Common operations
- Monitoring commands

## Troubleshooting
- Common issues
- Solutions

## Maintenance
- Regular tasks
- Backup procedures

## References
- Documentation links
- Related resources

## Version History
- Change log
```

### Naming Conventions

#### File Naming

- Use lowercase with hyphens: `high-availability-cluster.md`
- Be descriptive but concise
- Place in appropriate category directory

#### Section Headers

- Use sentence case: "Setup Instructions" not "Setup instructions"
- Be consistent with template

#### Command Comments

```bash
# Good: Descriptive, explains purpose
sudo systemctl restart apache2  # Restart web server to apply changes

# Poor: States the obvious
sudo systemctl restart apache2  # Restart apache2
```

## Submission Process

### Before Submitting

1. **Test Your Blueprint**
   - Follow your own instructions in a fresh environment
   - Verify all commands work as documented
   - Test validation procedures
   - Confirm troubleshooting steps solve stated problems

2. **Review Checklist**
   - [ ] All commands tested and verified
   - [ ] No hardcoded personal information
   - [ ] Version numbers specified
   - [ ] Expected outputs documented
   - [ ] Troubleshooting section complete
   - [ ] References provided
   - [ ] Version history updated
   - [ ] No security vulnerabilities introduced

3. **Documentation**
   - [ ] README.md updated if adding new category
   - [ ] Links in other documents updated if needed
   - [ ] Clear commit messages
   - [ ] Pull request description complete

### Pull Request Description

Provide a clear description:

```markdown
## Description
Brief description of the blueprint or changes

## Type of Change
- [ ] New blueprint
- [ ] Enhancement to existing blueprint
- [ ] Bug fix
- [ ] Documentation update
- [ ] Automation script

## Testing
Describe how you tested the changes:
- Environment used (hypervisor, OS versions, etc.)
- Steps followed
- Results of validation procedures

## Checklist
- [ ] Followed template structure
- [ ] Tested all commands
- [ ] Updated version history
- [ ] Added/updated references
- [ ] No security issues

## Additional Notes
Any additional context or notes for reviewers
```

## Review Process

### What to Expect

1. **Initial Review** (1-3 days)
   - Maintainers review for completeness
   - Check if guidelines are followed
   - Verify no obvious issues

2. **Technical Review** (3-7 days)
   - Detailed review of technical accuracy
   - Testing of commands and procedures
   - Feedback on improvements

3. **Revisions** (as needed)
   - Address reviewer feedback
   - Update pull request
   - Re-test if needed

4. **Approval and Merge**
   - Final approval from maintainers
   - Merge into main repository
   - Acknowledgment of contribution

### Review Criteria

Reviewers evaluate:

- **Technical Accuracy**: Commands work as documented
- **Completeness**: All sections adequately covered
- **Clarity**: Instructions are clear and easy to follow
- **Testing**: Evidence of thorough testing
- **Quality**: Meets project standards
- **Security**: No security vulnerabilities introduced

### Addressing Feedback

- Respond to all review comments
- Update your branch with changes
- Re-request review after updates
- Be open to suggestions and improvements

## Style Guide

### Markdown Formatting

#### Headers

```markdown
# Main Title (H1) - Used for blueprint title only
## Major Section (H2) - Overview, Architecture, etc.
### Subsection (H3) - Detailed topics
#### Minor Subsection (H4) - Fine details
```

#### Code Blocks

Always specify language:

```markdown
```bash
sudo apt update
```

```python
import os
```

```yaml
version: '3'
```
```

#### Lists

Use consistent formatting:

```markdown
Unordered lists:
- Item one
- Item two
  - Sub-item
  - Sub-item

Ordered lists:
1. First step
2. Second step
   - Additional detail
3. Third step
```

#### Tables

Use consistent spacing:

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
| Data 4   | Data 5   | Data 6   |
```

### Command Documentation

#### Include Context

```bash
# Update system packages to ensure latest security patches
sudo apt update && sudo apt upgrade -y

# Install web server and dependencies
sudo apt install -y apache2 php libapache2-mod-php
```

#### Show Expected Output

```bash
# Check service status
systemctl status apache2

# Expected output:
# ● apache2.service - The Apache HTTP Server
#    Loaded: loaded
#    Active: active (running)
```

#### Handle Errors

```bash
# Start service (may fail if port is in use)
sudo systemctl start apache2

# If error "Address already in use":
# 1. Check what's using port 80: sudo lsof -i :80
# 2. Stop the conflicting service
# 3. Try starting apache2 again
```

### Language and Tone

- **Be Clear**: Use simple, direct language
- **Be Professional**: Maintain technical professionalism
- **Be Inclusive**: Use "we", "you", not gendered terms
- **Be Precise**: Specify exact versions, paths, commands

#### Examples

**Good:**
```markdown
Install the Apache web server to serve HTTP requests. This will also 
install required PHP modules for dynamic content.
```

**Poor:**
```markdown
Install apache. You'll need php stuff too.
```

## Common Contribution Scenarios

### Adding a New Blueprint

1. Create file in appropriate category
2. Use template as starting point
3. Fill all sections completely
4. Test thoroughly
5. Submit pull request

### Fixing a Bug

1. Identify the issue clearly
2. Test the fix
3. Update documentation if needed
4. Submit pull request with clear description

### Improving Documentation

1. Identify unclear or missing information
2. Improve clarity or add details
3. Verify technical accuracy
4. Submit pull request

### Adding Automation

1. Create script in appropriate location
2. Document usage clearly
3. Test in multiple scenarios
4. Submit with documentation updates

## Questions or Issues?

- **Documentation Questions**: Open an issue with the "documentation" label
- **Technical Questions**: Open an issue with the "question" label
- **Bug Reports**: Open an issue with the "bug" label
- **Feature Requests**: Open an issue with the "enhancement" label

## Recognition

Contributors will be:
- Listed in the version history of blueprints they contribute to
- Acknowledged in release notes for significant contributions
- Added to the CONTRIBUTORS.md file

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

## Additional Resources

- [Markdown Guide](https://www.markdownguide.org/)
- [Git Handbook](https://guides.github.com/introduction/git-handbook/)
- [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/)

## Thank You!

Your contributions help create valuable resources for the systems community. Thank you for taking the time to contribute!
