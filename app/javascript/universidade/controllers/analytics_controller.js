import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Track page view on initial load
    this.trackPageView()
    
    // Track page views on Turbo navigation
    document.addEventListener('turbo:load', this.trackPageView.bind(this))
  }

  disconnect() {
    document.removeEventListener('turbo:load', this.trackPageView.bind(this))
  }

  trackPageView() {
    if (typeof gtag !== 'undefined') {
      gtag('event', 'page_view', {
        page_location: window.location.href,
        page_path: window.location.pathname,
        page_title: document.title
      })
    }
  }

  // Track content completion
  trackCompletion(event) {
    const button = event.currentTarget
    const contentId = button.dataset.contentId
    const contentTitle = button.dataset.contentTitle
    
    if (typeof gtag !== 'undefined') {
      gtag('event', 'complete_content', {
        event_category: 'engagement',
        event_label: contentTitle,
        content_id: contentId,
        content_title: contentTitle
      })
    }
  }

  // Track search
  trackSearch(event) {
    const form = event.currentTarget
    const searchInput = form.querySelector('input[name="q"]')
    const searchTerm = searchInput ? searchInput.value : ''
    
    if (searchTerm && typeof gtag !== 'undefined') {
      gtag('event', 'search', {
        search_term: searchTerm
      })
    }
  }

  // Track navigation between content
  trackNavigation(event) {
    const link = event.currentTarget
    const direction = link.dataset.direction || 'unknown'
    const fromContent = link.dataset.fromContent || ''
    const toContent = link.dataset.toContent || ''
    
    if (typeof gtag !== 'undefined') {
      gtag('event', 'content_navigation', {
        event_category: 'navigation',
        event_label: direction,
        direction: direction,
        from_content: fromContent,
        to_content: toContent
      })
    }
  }

  // Track feedback submission
  trackFeedback(event) {
    const button = event.currentTarget
    const sentiment = button.dataset.sentiment
    const contentId = button.dataset.contentId
    
    if (typeof gtag !== 'undefined') {
      gtag('event', 'submit_feedback', {
        event_category: 'engagement',
        event_label: sentiment,
        sentiment: sentiment,
        content_id: contentId
      })
    }
  }

  // Generic event tracking
  trackEvent(event) {
    const element = event.currentTarget
    const eventName = element.dataset.eventName
    const eventCategory = element.dataset.eventCategory || 'general'
    const eventLabel = element.dataset.eventLabel || ''
    
    if (eventName && typeof gtag !== 'undefined') {
      gtag('event', eventName, {
        event_category: eventCategory,
        event_label: eventLabel
      })
    }
  }
}
