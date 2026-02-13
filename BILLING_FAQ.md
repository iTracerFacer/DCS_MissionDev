# GitHub Copilot Billing FAQ

This document addresses common questions about GitHub Copilot billing, quotas, and premium request limits.

## Understanding Quota Exceeded Messages

If you see a message stating you're over your quota (e.g., "318% over quota"), this means:

1. **Your usage has exceeded your current plan limits** - GitHub Copilot tracks your API requests and has limits based on your subscription tier
2. **Premium requests** refer to advanced AI features that consume more resources (like GPT-4 based completions)
3. **The percentage** indicates how much over the limit you are

## What to Do When You Hit Your Quota

### Immediate Steps

1. **Check Your Current Usage**
   - Go to your GitHub Settings → Billing & plans → Plans and usage
   - Review your current usage metrics and limits

2. **Increase Your Budget**
   - Navigate to GitHub Settings → Billing & plans → Spending limits
   - Adjust your spending limit for GitHub Copilot
   - **Note: Changes may take 5-15 minutes to propagate through the system**

3. **Wait for the Quota to Reset**
   - Quotas typically reset at the beginning of each billing cycle
   - Check when your current billing period ends

### Does It Take Time?

**Yes**, when you increase your budget:
- **System propagation**: 5-15 minutes for the change to take effect across GitHub's infrastructure
- **Cache clearing**: Your local VS Code or IDE may need to refresh its authentication
- **Quota recalculation**: The backend needs to recalculate your available quota

### Troubleshooting Steps

If you're still stuck after increasing your budget:

1. **Sign out and sign back in** to your IDE (VS Code, JetBrains, etc.)
   - This refreshes your authentication token with updated quota information

2. **Clear the Copilot cache**
   - VS Code: Command Palette → "Developer: Reload Window"
   - Or restart your IDE completely

3. **Wait 15-30 minutes** after increasing your budget
   - System changes are not always instantaneous

4. **Check for service status**
   - Visit https://www.githubstatus.com/ to see if there are any ongoing issues

5. **Contact GitHub Support** if issues persist after 1 hour
   - Go to https://support.github.com/
   - Provide your account details and explain the situation

## Understanding Different Request Types

- **Standard requests**: Basic code completions and suggestions
- **Premium requests**: Advanced features like:
  - Multi-file context analysis
  - Complex code generation
  - Chat-based coding assistance
  - Large context window operations

## Best Practices to Manage Usage

1. **Monitor your usage regularly** through the billing dashboard
2. **Set up spending alerts** to be notified before hitting limits
3. **Use standard completions** when possible instead of always using chat/premium features
4. **Plan for high-usage periods** if you're working on large projects

## Additional Resources

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [GitHub Billing Documentation](https://docs.github.com/en/billing)
- [GitHub Support](https://support.github.com/)

---

**Note**: This repository is for DCS (Digital Combat Simulator) mission development. If you have questions about DCS mission scripting or development, please open an issue with the appropriate tags.
