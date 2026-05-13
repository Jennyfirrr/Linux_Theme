#ifndef FOX_VAULT_STORE_HPP
#define FOX_VAULT_STORE_HPP

#include <cstdint>
#include <string>
#include <unordered_map>
#include <vector>

namespace fox_vault {

// SecureBuffer: a value held on an mlock()'d, anonymous, MAP_PRIVATE
// region. Contents are XOR-obfuscated against a per-process session
// key so a heap dump shows opaque bytes (not plaintext). Destructor
// explicit_bzero's the buffer before munmap'ing.
class SecureBuffer {
public:
    SecureBuffer() = default;
    SecureBuffer(const uint8_t* data, size_t len, const uint8_t* key, size_t key_len);
    SecureBuffer(SecureBuffer&& other) noexcept;
    SecureBuffer& operator=(SecureBuffer&& other) noexcept;
    SecureBuffer(const SecureBuffer&)            = delete;
    SecureBuffer& operator=(const SecureBuffer&) = delete;
    ~SecureBuffer();

    // Returns a plaintext copy. Caller is responsible for wiping it.
    std::string reveal(const uint8_t* key, size_t key_len) const;

    size_t size() const { return len_; }

private:
    void reset() noexcept;

    void*  page_ = nullptr;   // mmap'd region
    size_t map_size_ = 0;     // bytes actually mmap'd (page-rounded)
    size_t len_  = 0;         // logical length (<= map_size_)
};

class Vault {
public:
    Vault();
    ~Vault();

    bool set(const std::string& name, const uint8_t* data, size_t len);
    bool get(const std::string& name, std::string& out) const;
    bool del(const std::string& name);
    void clear();
    std::vector<std::string> list() const;

private:
    std::unordered_map<std::string, SecureBuffer> store_;
    uint8_t session_key_[32]{};
};

}  // namespace fox_vault

#endif
